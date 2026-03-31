#!/bin/bash

# ============================================================
#
#   Flutter Clean Architecture - Scaffold Generator
#
# ============================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║   Flutter Clean Architecture - Scaffold Generator    ║${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

read -p "$(echo -e ${YELLOW}${BOLD}"Enter the feature name (e.g., product): "${RESET})" FEATURE_RAW

if [[ -z "$FEATURE_RAW" ]]; then
  echo -e "${RED}❌ You didn't enter a name!${RESET}"
  exit 1
fi

FEATURE=$(echo "$FEATURE_RAW" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
BASE_PATH="lib/features/${FEATURE}"

if [[ -d "$BASE_PATH" ]]; then
  echo -e "${RED}⚠️  The feature '${FEATURE}' already exists.${RESET}"
  read -p "$(echo -e ${YELLOW}"Do you want to overwrite it? (y/n): "${RESET})" OVERWRITE
  if [[ "$OVERWRITE" != "y" ]]; then
    echo -e "${CYAN}Cancelled.${RESET}"
    exit 0
  fi
fi

echo ""
echo -e "${CYAN}⚙️  Creating scaffold for ${BOLD}${FEATURE}${RESET}"
echo ""

make() {
  local PATH_="$1"
  mkdir -p "$(dirname "$PATH_")"
  touch "$PATH_"
  echo -e "  ${GREEN}✔${RESET} $PATH_"
}

# ══════════════════════════════════════════════════════════════
echo -e "${BOLD}📂 Domain${RESET}"
make "${BASE_PATH}/domain/entities/${FEATURE}_G_entity.dart"
make "${BASE_PATH}/domain/repositories/${FEAtestTURE}_G_repository.dart"
make "${BASE_PATH}/domain/usecases/get_${FEATURE}_G_s_usecase.dart"
make "${BASE_PATH}/domain/usecases/get_${FEATURE}_G_by_id_usecase.dart"
make "${BASE_PATH}/domain/usecases/create_${FEATURE}_G_usecase.dart"

echo ""
echo -e "${BOLD}📂 Data${RESET}"
make "${BASE_PATH}/data/models/${FEATURE}_G_model.dart"
make "${BASE_PATH}/data/datasources/${FEATURE}_G_remote_datasource.dart"
make "${BASE_PATH}/data/datasources/${FEATURE}_G_local_datasource.dart"
make "${BASE_PATH}/data/repositories/${FEATURE}_G_repository_impl.dart"

echo ""
echo -e "${BOLD}📂 Presentation${RESET}"
make "${BASE_PATH}/presentation/pages/${FEATURE}s_G_page.dart"
make "${BASE_PATH}/presentation/widgets/${FEATURE}_G_card.dart"
make "${BASE_PATH}/presentation/widgets/${FEATURE}_G_list.dart"
make "${BASE_PATH}/presentation/widgets/${FEATURE}_G_search_bar.dart"
make "${BASE_PATH}/presentation/controllers/${FEATURE}_G_controller.dart"
make "${BASE_PATH}/presentation/controllers/${FEATURE}_G_binding.dart"

# ══════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║             scaffold created successfully            ║${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
find "$BASE_PATH" -type f | sort | sed 's|^|   |'
echo ""