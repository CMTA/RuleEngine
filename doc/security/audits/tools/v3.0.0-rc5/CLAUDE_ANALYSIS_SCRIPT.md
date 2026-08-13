# Script review — findings and fixes

| | |
|---|---|
| **Scope** | `script/` (2 Foundry scripts), `doc/script/` (4 shell scripts), `package.json` npm scripts |
| **Base commit** | `50165c7` + working tree |
| **Date** | 2026-08-13 |
| **Produced with** | Claude Code |

Findings are grouped by script family and given stable IDs (`S-n`). Each states whether it was **verified by
running it** or **reasoned from the source** — the distinction matters, and both appear below.

One finding, **S-1**, was a functional defect: `RuleEngineScript.s.sol` produced a deployment in which no
transfer could ever succeed. It was not a security issue (it failed closed, it opened nothing), but anyone
using that script as a deployment recipe got a broken system. It is now fixed and pinned by a test.

**All 12 findings have been fixed.** The sections below keep each finding as originally written, with the
applied fix recorded under it.

## Disposition summary

| ID | Script | Finding | Outcome |
|----|--------|---------|---------|
| S-1 | `RuleEngineScript.s.sol` | The CMTAT is never bound to the engine — all transfers revert | ✅ fixed — token passed to the constructor |
| S-2 | `RuleEngineScript.s.sol` | Low-level `.call` + bare `require(success)` succeeds against an EOA | ✅ fixed — typed call |
| S-3 | `RuleEngineScript.s.sol` | Ships an empty whitelist, so nothing can transfer or mint even once bound | ✅ fixed — deployer + `address(0)` listed |
| S-4 | `test/script/RuleEngineScript.t.sol` | Asserts only that `run()` does not revert | ✅ fixed — 5 assertions + a live mint |
| S-5 | `CMTATWithRuleEngineScript.s.sol` | Correct — the reference for how S-1/S-2 should look | ⬜ no change needed |
| S-6 | 3 of 4 shell scripts | Broken shebang `#/bin/bash` (missing `!`), files are executable | ✅ fixed — `#!/bin/bash` in all three |
| S-7 | inheritance + report | `find $dir` — undefined variable; works only by GNU-find accident | ✅ fixed — quoted `"$DIR"` |
| S-8 | `script_surya_report.sh` | `mkdir` without `-p` creates a hidden ordering dependency | ✅ fixed — `mkdir -p`, verified standalone |
| S-9 | `script_surya_inheritance.sh` | Guard checks a directory that is never created | ✅ fixed — guard and target aligned |
| S-10 | 3 surya scripts | No `set -euo pipefail`; a surya failure silently yields a 0-byte PNG | ✅ fixed — added to all three |
| S-11 | 3 surya scripts | `for i in $(find …)` word-splits on whitespace in paths | ✅ fixed — `-print0` / `read -d ''` |
| S-12 | `convert_links_for_pdf.sh` | Well written — the in-repo example of a correct shell script | ⬜ no change needed |
| S-13 | npm `surya:*`, `uml:*` | Write output into the repository root, and it is not gitignored | ✅ fixed — output moved to `docOut/` |
| S-14 | `convert_links_for_pdf.sh` | Default input still points at the root README after the README split | ✅ fixed — defaults to `doc/README.md` |

**14 entries — 12 findings, all fixed; 2 positive references requiring no change.**

### What was verified after the fixes

| Check | Result |
|---|---|
| `forge build` | 0 errors |
| `forge test` | **336 passed**, 0 failed |
| S-1 regression test | Fails when the binding is reverted (`the token must be bound to the engine`), passes when restored |
| `./script_surya_graph.sh` | Runs via `./` (shebang fixed) — 47 files, 0 empty |
| `./script_surya_inheritance.sh` | 47 files, 0 empty |
| `./script_surya_report.sh` | 47 files, 0 empty — **and now runs standalone with no `docOut/` present** |
| `npm run surya:report` | Writes into `docOut/`; repository root stays clean |
| `package.json` | Valid JSON |
| Solidity style checker | 0 violations across 47 files |

---

## A. Foundry scripts (`script/`)

### S-1. `RuleEngineScript` leaves the CMTAT unbound, so every transfer reverts

**Verified by running the script in a test.**

```solidity
RuleEngine ruleEngine = new RuleEngine(admin, address(0), address(0));
//                                                        ^^^^^^^^^^ tokenContract
ruleEngine.addRule(ruleWhitelist);
(bool success,) =
    address(cmtatAddress).call(abi.encodeCall(ValidationModuleRuleEngine.setRuleEngine, ruleEngine));
```

The third constructor argument is `tokenContract`. Passing `address(0)` binds nothing, and the script never
calls `bindToken` afterwards. The token is pointed at the engine, but the engine does not recognise the token.

Because `transferred`, `created` and `destroyed` are all guarded by `onlyBoundToken`, **every** transfer, mint
and burn then reverts with `RuleEngine_ERC3643Compliance_UnauthorizedCaller`.

Running the script and inspecting the result:

```
engine set on token   : 0x1240FA2A84dd9157a0e76B5Cfe98B1d52268B264
token bound to engine?: false
getTokenBound         : 0x0000000000000000000000000000000000000000
```

and a subsequent `cmtat.mint(...)` reverts.

**Fixed** — the token is now passed to the constructor, exactly as the sibling script already did:

```solidity
RuleEngine ruleEngine = new RuleEngine(admin, address(0), cmtatAddress);
```

The equivalent alternative — keeping the constructor as-is and calling `ruleEngine.bindToken(cmtatAddress)`
before `setRuleEngine` — was rejected because the constructor form matches the sibling script and cannot be
forgotten as a separate step.

The NatSpec now states why the binding matters, so a future edit that drops it has to ignore an explicit
warning. `testRun` pins the behaviour: reverting the constructor argument makes it fail with
`the token must be bound to the engine`.

### S-2. The low-level call silently succeeds when `CMTAT_ADDRESS` is not a contract

**Verified by running the script against an EOA.**

```solidity
(bool success,) =
    address(cmtatAddress).call(abi.encodeCall(ValidationModuleRuleEngine.setRuleEngine, ruleEngine));
require(success);
```

Two problems, both consequences of using a low-level call where a typed one would do:

1. **A call to an address with no code returns `success = true`.** A typo'd or stale `CMTAT_ADDRESS`
   environment variable pointing at an EOA makes the script complete normally while configuring nothing. A
   test that sets `CMTAT_ADDRESS` to a fresh `makeAddr(...)` runs the script to completion without reverting.
2. **`require(success)` discards the revert reason.** The realistic failure — the deployer lacking
   `DEFAULT_ADMIN_ROLE` on the token — surfaces as a bare `require` failure with no diagnostic, on a script
   that may have already broadcast several deployment transactions.

**Fixed** — it now goes through the typed interface, as `CMTATWithRuleEngineScript` does:

```solidity
ValidationModuleRuleEngine(cmtatAddress).setRuleEngine(IRuleEngine(address(ruleEngine)));
```

This reverts with the real reason and cannot silently succeed against an EOA, because a typed call to a
codeless address fails on the return-data decode.

### S-3. The deployed whitelist is empty

**Reasoned from the source, consistent with the rule's tested behaviour.**

The script deploys `RuleWhitelistMock` and adds it to the engine without listing any address. Once S-1 is
fixed, the resulting deployment still rejects every transfer, because no participant is whitelisted — and
rejects every mint, because `address(0)` is not listed either (see finding `F-2` in
[CLAUDE_ANALYSIS.md](./CLAUDE_ANALYSIS.md)).

This may well have been deliberate for a demo whose point is "deploy the wiring, configure it yourself". But
the header did not say so, and the natural reading of an example deployment script is that its output works.

**Fixed** — the script now seeds the list so the demo deployment is usable as-is:

```solidity
address[] memory listed = new address[](2);
listed[0] = admin;
listed[1] = address(0);   // required for mint and burn; the rule treats it as an ordinary participant
ruleWhitelist.addAddressesToTheList(listed);
```

The NatSpec states both that this is demo seeding to be replaced with the real address list, and why
`address(0)` has to be present. `testRun` now performs a real mint against the deployed set-up, so the
combination of S-1 and S-3 is covered end to end rather than assumed.

### S-4. The script test asserts nothing about the result

`test/script/RuleEngineScript.t.sol` ends with:

```solidity
RuleEngineScript deployScript = new RuleEngineScript();
deployScript.run();
```

There is no assertion. The test passes as long as `run()` does not revert, which is why **S-1 has been
invisible**: the script does exactly what it says and produces a non-functional deployment, and the test is
satisfied.

**Fixed** — the test now asserts the post-conditions the script exists to establish:

```solidity
assertEq(address(cmtat.ruleEngine()), address(engine));
assertTrue(engine.isTokenBound(address(cmtat)));
assertEq(engine.rulesCount(), 1);
```

The first two would have failed before an S-1 fix and pass after, which is the definition of a useful
regression test.

### S-5. `CMTATWithRuleEngineScript` is correct — use it as the reference

Recorded deliberately, because the contrast is the strongest evidence that S-1 and S-2 are defects rather than
design choices. The sibling script, in the same directory, does both things properly:

```solidity
RuleEngine ruleEngine = new RuleEngine(admin, trustedForwarder, address(cmtatContract)); // binds
cmtatContract.setRuleEngine(ruleEngine);                                                 // typed call
```

Same author, same purpose, same directory — one binds the token and uses a typed call, the other does neither.

---

## B. Shell scripts (`doc/script/`)

### S-6. Broken shebang in three of the four scripts

**Verified by inspecting the raw bytes.**

| Script | First line |
|---|---|
| `convert_links_for_pdf.sh` | `#!/bin/bash` — correct |
| `script_surya_graph.sh` | `#/bin/bash` — **missing `!`** |
| `script_surya_inheritance.sh` | `#/bin/bash` — **missing `!`** |
| `script_surya_report.sh` | `#/bin/bash` — **missing `!`** |

`#/bin/bash` is an ordinary comment, not an interpreter directive. All four files carry the executable bit
(`-rwxrwxr-x`), so they are meant to be run as `./script_surya_graph.sh` — and in that form the kernel finds no
interpreter and the behaviour falls back to the caller's shell. It happens to work when that is bash; it is
undefined otherwise. Invoking them as `bash script_surya_graph.sh` masks the problem entirely, which is
presumably why it has survived.

**Fixed** — the missing `!` was added in all three. Each script was then executed as `./script_….sh` (not `bash script_….sh`) to confirm the shebang is honoured; all three completed with exit code 0.

### S-7. `find $dir` uses an undefined variable

**Verified by reproducing the expansion.**

`script_surya_inheritance.sh:10` and `script_surya_report.sh:10`:

```bash
DIR=$(pwd)                        # sets DIR (uppercase)
for i in $(find $dir -type f);    # reads dir  (lowercase) — never set
```

`$dir` expands to nothing, so the command becomes `find -type f`. GNU find accepts that and defaults to `.`,
which is why these scripts appear to work. Reproduced here: `find -type f` with an empty variable returns the
same file list as `find . -type f`, exit code 0.

Two consequences:

- **Portability** — BSD/macOS `find` requires a path operand and errors out. These two scripts are therefore
  expected to fail on macOS. *(Reasoned, not tested — no BSD environment available here.)*
- The third script, `script_surya_graph.sh:12`, correctly uses `$DIR`. Another same-directory inconsistency.

**Fixed** — all three scripts now use `find "$DIR" -type f -name '*.sol'`, quoted, which is also portable to BSD/macOS find.

### S-8. `script_surya_report.sh` uses `mkdir` without `-p`

```bash
DIR_OUT=${DIR}/docOut/surya_report
if ! [ -d "$DIR_OUT" ]; then
    mkdir ./docOut/surya_report      # graph.sh uses `mkdir -p`
fi
```

Without `-p`, this fails when `docOut/` does not yet exist — which is the case on a clean checkout, since
`docOut/` is gitignored. The script only works if `script_surya_graph.sh` (which uses `mkdir -p`) has run
first. That ordering requirement is real but undocumented in the scripts themselves.

**Fixed** — now `mkdir -p`, matching the graph script. Verified by moving `docOut/` aside to reproduce the clean-checkout condition and running `./script_surya_report.sh` alone: it completed with exit code 0 and produced 47 reports. The ordering dependency is gone.

### S-9. The output guard in `script_surya_inheritance.sh` checks the wrong path

```bash
DIR_OUT=${DIR}/docOut/inheritance          # checked
...
    mkdir -p ./docOut/surya_inheritance    # created
```

The guard tests `docOut/inheritance`, which nothing ever creates, so the condition is always true and `mkdir
-p` runs on every invocation. Harmless because of `-p`, but the guard is dead code and the mismatch suggests a
copy-paste that was only half-updated.

**Fixed** — the guard and the created directory are now the same path, and both scripts write to `"${DIR_OUT}"` rather than a second hard-coded relative path, so the two cannot drift apart again.

### S-10. No `set -euo pipefail`, so a failing surya call produces a silent empty PNG

None of the three surya scripts set any shell options. Combined with the pipeline

```bash
npx surya inheritance $i | dot -Tpng > ../docOut/surya_inheritance/surya_inheritance_$filename.png;
```

a failure in `npx surya` still leaves `dot` running on empty input, which writes a **0-byte or near-empty PNG**
and returns 0. The loop continues, the script exits successfully, and the failure is only discoverable by
noticing the image is blank later.

This is not hypothetical: the known surya crash on contracts calling `super.<fn>()` manifests exactly this way.

**Fixed** — `set -euo pipefail` added to all three, so a broken render stops the run and names the
file. `convert_links_for_pdf.sh` already sets `-e`.

### S-11. `for i in $(find …)` word-splits on paths containing whitespace

All three surya scripts iterate command substitution output unquoted. No current path under `src/` contains a
space, so this is latent rather than live, but it is one directory rename away from producing confusing
errors.

**Fixed** — all three now use `find … -print0` piped into `while IFS= read -r -d ''`, and every path expansion is quoted.

### S-12. `convert_links_for_pdf.sh` is the example to copy

Correct shebang, `set -e`, a usage message with examples, input-file validation, `mktemp` for scratch state,
and a placeholder token to sidestep `sed` escaping in URLs. The surya scripts are well below the standard this
one sets, in the same directory.

---

## C. npm scripts (`package.json`)

### S-13. Surya and UML scripts write into the repository root

```json
"surya:report": "npx surya mdreport surya_report_ruleEngine.md src/deployment/RuleEngine.sol",
"surya:graph":  "npx surya graph src/deployment/RuleEngine.sol | dot -Tpng > surya_graph_RuleEngine.png"
```

Both write to the repo root. `.gitignore` covers `docOut/` but neither `surya_report_ruleEngine.md` nor
`surya_graph_RuleEngine.png`, so running either leaves untracked files in the root that can be committed by
accident. The shell scripts in `doc/script/` write into `docOut/` and are then moved under `doc/schema/surya/`
— two different conventions for the same tool.

**Fixed** — all five scripts now `mkdir -p` and write beneath `docOut/` (already gitignored). Verified with `npm run surya:report`: the file lands in `docOut/surya_report/` and the repository root stays clean. Superseded guidance follows:

Original suggestion — write into `docOut/` (already gitignored) or directly under `doc/schema/`, and/or add the
two filenames to `.gitignore`.

The `uml:*` scripts have the same characteristic via `sol2uml`'s default output location.

### S-14. `convert_links_for_pdf.sh` now defaults to the short README

```bash
INPUT_FILE="${2:-../../README.md}"
```

From `doc/script/`, that resolves to the root `README.md`. Since the README was split, the root file is a
122-line overview while the full documentation — the thing a PDF is presumably wanted for — is
`doc/README.md` (1780 lines). The default therefore now converts the wrong document.

This is a consequence of the README split, not an original defect in the script.

**Fixed** — the default is now `../README.md` (i.e. `doc/README.md`), with a comment stating why. Superseded guidance follows:

Original suggestion — change the default to `../README.md`, or leave it and document that
the input file must be passed explicitly.

---

## Verification notes

- **S-1 and S-2 were verified by executing `RuleEngineScript.run()`** inside a temporary Foundry test: once
  against a real CMTAT (showing `isTokenBound == false` and a reverting mint), once against an EOA (showing the
  script completes). Both probe files were deleted afterwards; the suite is back to **336 tests, 0 failures**.
- **S-6, S-7, S-8, S-9** were verified by reading the script sources and, for S-7, reproducing the empty-variable
  `find` expansion in a scratch directory.
- **The BSD/macOS half of S-7 is reasoned, not tested** — no BSD environment was available.
- **S-3, S-11, S-13, S-14** were reasoned from source and file inspection at discovery time.

After the fixes were applied, the following were additionally executed:

- All three surya scripts were run **as `./script_….sh`**, which exercises the corrected shebang rather than
  bypassing it with `bash script_….sh`. Each produced 47 outputs with no empty files.
- `script_surya_report.sh` was run with `docOut/` moved aside, reproducing the clean-checkout condition that
  previously broke it (S-8). It completed with exit code 0.
- `npm run surya:report` was run to confirm S-13: the output lands in `docOut/surya_report/` and the repository
  root stays clean.
- The S-1 fix was reverted and `testRun` confirmed to **fail** (`the token must be bound to the engine`) before
  being restored, so the new assertions are a real guard rather than a guess.
- **The BSD/macOS portability improvement in S-7 remains reasoned, not tested** — no BSD environment was
  available. The quoted `find "$DIR"` form is correct on both, but only GNU find was exercised here.

`docOut/` holds regenerated scratch output from these runs. It is gitignored and can be deleted.
