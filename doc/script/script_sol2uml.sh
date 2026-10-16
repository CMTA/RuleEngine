#!/bin/bash
# Generate the class diagrams referenced by doc/README.md with sol2uml.
# Output: doc/schema/sol2uml/ (committed, unlike the docOut/ scripts next to this one)
#
# One diagram per contract or interface, filtered with -b/-d 0 so a file holding several
# interfaces yields one image each. Paths stay relative to the repository root: sol2uml prints
# the path it is given under the class name, so an absolute one would write machine-specific
# paths into the committed images.
set -euo pipefail

cd "$(dirname "$0")/../../"
DIR_OUT="doc/schema/sol2uml"
mkdir -p "$DIR_OUT"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
command -v dot >/dev/null || { echo "Graphviz dot is required" >&2; exit 1; }

# "<image name>|<source file>|<contract name>"
DIAGRAMS=(
    "RuleEngineUML|src/deployment/accessControl/RuleEngine.sol|RuleEngine"
    "RuleEngineOwnableUML|src/deployment/ownable/RuleEngineOwnable.sol|RuleEngineOwnable"
    "RuleEngineOwnable2StepUML|src/deployment/ownable/RuleEngineOwnable2Step.sol|RuleEngineOwnable2Step"
    "RuleEngine2771UML|src/deployment/accessControl/RuleEngine2771.sol|RuleEngine2771"
    "RuleEngineOwnable2771UML|src/deployment/ownable/RuleEngineOwnable2771.sol|RuleEngineOwnable2771"
    "RuleEngineOwnable2Step2771UML|src/deployment/ownable/RuleEngineOwnable2Step2771.sol|RuleEngineOwnable2Step2771"
    "RuleEngineBaseUML|src/RuleEngineBase.sol|RuleEngineBase"
    "VersionModuleUML|src/modules/VersionModule.sol|VersionModule"
    "RuleManagementModuleUML|src/modules/RulesManagementModule.sol|RulesManagementModule"
    "TokenBindingModuleUML|src/modules/TokenBindingModule.sol|TokenBindingModule"
    "TokenBindingExtendedModuleUML|src/modules/TokenBindingExtendedModule.sol|TokenBindingExtendedModule"
    "ERC3643ComplianceModuleUML|src/modules/ERC3643ComplianceModule.sol|ERC3643ComplianceModule"
    "ERC3643ComplianceExtendedModuleUML|src/modules/ERC3643ComplianceExtendedModule.sol|ERC3643ComplianceExtendedModule"
    "IRuleUML|src/interfaces/IRule.sol|IRule"
    "IRuleEngineUML|lib/CMTAT/contracts/interfaces/engine/IRuleEngine.sol|IRuleEngine"
    "IERC1404UML|lib/CMTAT/contracts/interfaces/tokenization/draft-IERC1404.sol|IERC1404"
    "IERC1404ExtendUML|lib/CMTAT/contracts/interfaces/tokenization/draft-IERC1404.sol|IERC1404Extend"
    "IERC7551ComplianceUML|lib/CMTAT/contracts/interfaces/tokenization/draft-IERC7551.sol|IERC7551Compliance"
    "IERC3643ComplianceReadUML|lib/CMTAT/contracts/interfaces/tokenization/IERC3643Partial.sol|IERC3643ComplianceRead"
    "IERC3643IComplianceContractUML|lib/CMTAT/contracts/interfaces/tokenization/IERC3643Partial.sol|IERC3643IComplianceContract"
)

for entry in "${DIAGRAMS[@]}"; do
    IFS='|' read -r image source contract <<< "$entry"
    if [ ! -f "$source" ]; then
        echo "Missing source: $source (submodule not initialized?)" >&2
        exit 1
    fi
    # sol2uml renders PNG through a headless Chrome (puppeteer), which cannot start where unprivileged user
    # namespaces are disabled (Ubuntu 23.10+ AppArmor: "No usable sandbox"). Emit Graphviz dot instead and
    # render it with dot, the same engine sol2uml uses; 96 dpi matches sol2uml's own PNG scale.
    npx sol2uml class "$source" -b "$contract" -d 0 -f dot -o "${TMP_DIR}/${image}.dot"
    dot -Tpng -Gdpi=96 "${TMP_DIR}/${image}.dot" -o "${DIR_OUT}/${image}.png"
done
