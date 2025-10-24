#!/bin/bash

# DAO-AI-Accelerator Project Initialization Script
# Version: 1.0.0
# Purpose: Configures a new DAO project from the accelerator template

set -e  # Exit on error

echo "=========================================="
echo "  DAO-AI-Accelerator Project Setup"
echo "=========================================="
echo ""
echo "This script will configure your new DAO project."
echo "All {{PLACEHOLDERS}} will be replaced with your values."
echo ""

# Collect configuration from user
read -p "Enter Project Name (e.g., BankXYZ): " PROJECT_NAME
read -p "Enter Client Name (e.g., Bank XYZ): " CLIENT_NAME
read -p "Enter Salesforce Org Alias (e.g., bankxyz-dev): " ORG_ALIAS
read -p "Enter Integration Source Name (e.g., ExternalApp): " INTEGRATION_SOURCE
read -p "Enter Salesforce Instance URL (e.g., https://test.salesforce.com): " INSTANCE_URL

echo ""
echo "=========================================="
echo "Configuration Summary:"
echo "=========================================="
echo "  Project Name:        $PROJECT_NAME"
echo "  Client Name:         $CLIENT_NAME"
echo "  Org Alias:           $ORG_ALIAS"
echo "  Integration Source:  $INTEGRATION_SOURCE"
echo "  Instance URL:        $INSTANCE_URL"
echo ""
read -p "Continue with setup? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "Starting setup..."
echo ""

# Function to replace placeholders in a file
replace_placeholders() {
    local file=$1
    if [ -f "$file" ]; then
        sed -i '' "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$file"
        sed -i '' "s/{{CLIENT_NAME}}/$CLIENT_NAME/g" "$file"
        sed -i '' "s/{{ORG_ALIAS}}/$ORG_ALIAS/g" "$file"
        sed -i '' "s/{{INTEGRATION_SOURCE}}/$INTEGRATION_SOURCE/g" "$file"
        sed -i '' "s|{{INSTANCE_URL}}|$INSTANCE_URL|g" "$file"
        echo "  ✓ Updated: $file"
    fi
}

# 1. Update configuration file
echo "[1/6] Updating accelerator-config.json..."
replace_placeholders "accelerator-config.json"

# 2. Update .cursorrules
echo "[2/6] Updating .cursorrules..."
replace_placeholders ".cursorrules"

# 3. Update PROJECT.md
echo "[3/6] Updating PROJECT.md..."
replace_placeholders "PROJECT.md"

# 4. Update all documentation files
echo "[4/6] Updating documentation files..."
find docs -type f -name "*.md" -print0 | while IFS= read -r -d '' file; do
    replace_placeholders "$file"
done

# 5. Update Postman collection (if exists)
echo "[5/6] Updating Postman collection..."
if [ -f "docs/04-implementation/DAO-API-Postman-Collection.json" ]; then
    replace_placeholders "docs/04-implementation/DAO-API-Postman-Collection.json"
fi

# 6. Update object field metadata
echo "[6/6] Updating object field descriptions..."
find force-app/main/default/objects -type f -name "*.xml" -print0 | while IFS= read -r -d '' file; do
    replace_placeholders "$file"
done

echo ""
echo "=========================================="
echo "  ✓ Setup Complete!"
echo "=========================================="
echo ""
echo "Your project is configured as:"
echo "  - Name: $PROJECT_NAME"
echo "  - Org: $ORG_ALIAS"
echo "  - Integration: $INTEGRATION_SOURCE"
echo ""
echo "Next Steps:"
echo "  1. Review accelerator-config.json"
echo "  2. Fill in docs/01-foundation/field-mappings-template.csv"
echo "  3. Authenticate: sf org login web --alias $ORG_ALIAS"
echo "  4. Deploy custom objects: sf project deploy start --source-dir force-app/main/default/objects"
echo "  5. Deploy Apex classes: sf project deploy start --source-dir force-app/main/default/classes"
echo "  6. Deploy LWC components: sf project deploy start --source-dir force-app/main/default/lwc"
echo "  7. Read docs/03-workflows/salesforce-user-workflow.md for LWC user journey"
echo "  8. Read docs/04-implementation/lwc-architecture.md for technical details"
echo ""
echo "Happy coding! 🚀"
echo ""

