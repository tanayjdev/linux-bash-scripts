#!/bin/bash

# ================================================
# User Creation Script
# ================================================

# ---------- CONFIGURATION ----------

DEFAULT_SHELL="/bin/bash"

DEFAULT_GROUP="developers"

HOME_BASE="/home"

LOG_FILE="/home/ubuntu/logs/user_creation.log"

MIN_USERNAME_LENGTH=3
MAX_USERNAME_LENGTH=32

# ---------- COLORS ----------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ================================================
# FUNCTION: LOG MESSAGE
# ================================================

log_message() {

 echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> $LOG_FILE

 echo "$1"
}

# ================================================
# FUNCTION: VALIDATE USERNAME
# ================================================

validate_username() {

 local USERNAME=$1

 # Length check
 local LENGTH=${#USERNAME}

 if [ $LENGTH -lt $MIN_USERNAME_LENGTH ]; then

  echo -e "${RED}Error: Username too short${NC}"

  return 1

 fi

 if [ $LENGTH -gt $MAX_USERNAME_LENGTH ]; then

  echo -e "${RED}Error: Username too long${NC}"

  return 1

 fi

 # Regex validation
 if [[ ! "$USERNAME" =~ ^[a-z][a-z0-9_-]*$ ]]; then

  echo -e "${RED}Error: Invalid username format${NC}"

  return 1

 fi

 # Existing user check
 if id "$USERNAME" &>/dev/null; then

  echo -e "${RED}Error: User already exists${NC}"

  return 1

 fi

 return 0
}

# ================================================
# FUNCTION: ENSURE GROUP EXISTS
# ================================================

ensure_group() {

 local GROUP=$1

 if ! getent group "$GROUP" &>/dev/null; then

  echo -e "${YELLOW}Creating group: $GROUP${NC}"

  sudo groupadd "$GROUP"

  log_message "Group created: $GROUP"

 else

  echo -e "${GREEN}Group exists: $GROUP${NC}"

 fi
}

# ================================================
# FUNCTION: CREATE USER
# ================================================

create_user() {

 local USERNAME=$1
 local FULL_NAME=$2
 local USER_GROUP=$3
 local ADD_SUDO=$4

 echo ""
 echo -e "${BLUE}--- Creating user: $USERNAME ---${NC}"

 # Validate
 validate_username "$USERNAME"

 if [ $? -ne 0 ]; then

  log_message "FAILED: Validation failed for $USERNAME"

  return 1

 fi

 # Create user
 sudo useradd \
  -m \
  -s "$DEFAULT_SHELL" \
  -c "$FULL_NAME" \
  -g "$USER_GROUP" \
  "$USERNAME"

 if [ $? -ne 0 ]; then

  echo -e "${RED}User creation failed${NC}"

  log_message "FAILED: Could not create $USERNAME"

  return 1

 fi

 # Temporary password
 TEMP_PASSWORD="${USERNAME}@$(date +%Y)"

 echo "$USERNAME:$TEMP_PASSWORD" | sudo chpasswd

 # Sudo access
 if [ "$ADD_SUDO" == "yes" ]; then

  sudo usermod -aG sudo "$USERNAME"

  echo -e "${YELLOW}Sudo granted${NC}"

  log_message "Sudo granted: $USERNAME"

 fi

 # Directory setup
 sudo mkdir -p /home/$USERNAME/{projects,scripts,logs}

 sudo chown -R $USERNAME:$USER_GROUP /home/$USERNAME

 # Welcome file
 sudo bash -c "cat > /home/$USERNAME/.welcome" << EOF
Welcome to the server, $FULL_NAME!

Username: $USERNAME
Home: /home/$USERNAME
Shell: $DEFAULT_SHELL

Please change your password:
passwd

Directories:
~/projects
~/scripts
~/logs
EOF

 sudo chown $USERNAME:$USER_GROUP /home/$USERNAME/.welcome

 echo -e "${GREEN}User created successfully${NC}"

 echo "Username: $USERNAME"
 echo "Group: $USER_GROUP"
 echo "Temp password: $TEMP_PASSWORD"

 log_message "SUCCESS: User created -> $USERNAME"

 return 0
}

# ================================================
# FUNCTION: CREATE USERS FROM FILE
# ================================================

create_from_file() {

 local FILE=$1

 if [ ! -f "$FILE" ]; then

  echo -e "${RED}File not found${NC}"

  return 1

 fi

 SUCCESS=0
 FAILED=0

 while IFS=',' read -r USERNAME FULL_NAME GROUP SUDO
 do

  # Skip comments
  [[ "$USERNAME" =~ ^#.*$ ]] && continue

  [ -z "$USERNAME" ] && continue

  # Trim spaces
  USERNAME=$(echo "$USERNAME" | tr -d ' ')

  FULL_NAME=$(echo "$FULL_NAME" | xargs)

  GROUP=$(echo "$GROUP" | tr -d ' ')

  SUDO=$(echo "$SUDO" | tr -d ' ')

  ensure_group "$GROUP"

  create_user "$USERNAME" "$FULL_NAME" "$GROUP" "$SUDO"

  if [ $? -eq 0 ]; then

   SUCCESS=$((SUCCESS + 1))

  else

   FAILED=$((FAILED + 1))

  fi

 done < "$FILE"

 echo ""
 echo -e "${BLUE}--- Batch Summary ---${NC}"

 echo -e "${GREEN}Created: $SUCCESS${NC}"

 echo -e "${RED}Failed: $FAILED${NC}"
}

# ================================================
# MAIN SCRIPT
# ================================================

mkdir -p /home/ubuntu/logs

echo -e "${BLUE}================================================${NC}"

echo -e "${BLUE} USER CREATION SCRIPT ${NC}"

echo -e "${BLUE}================================================${NC}"

echo ""

ensure_group "$DEFAULT_GROUP"

# Modes
if [ "$1" == "--file" ] && [ -n "$2" ]; then

 create_from_file "$2"

elif [ "$1" == "--interactive" ]; then

 read -p "Username: " USERNAME

 read -p "Full name: " FULL_NAME

 read -p "Group [$DEFAULT_GROUP]: " GROUP

 GROUP=${GROUP:-$DEFAULT_GROUP}

 read -p "Add sudo access? (yes/no): " ADD_SUDO

 ensure_group "$GROUP"

 create_user "$USERNAME" "$FULL_NAME" "$GROUP" "$ADD_SUDO"

else

 echo "Running demo mode..."

 create_user "devuser3" "Dev User Three" "$DEFAULT_GROUP" "no"

 create_user "devuser4" "Dev User Four" "$DEFAULT_GROUP" "yes"

fi

echo ""

echo "Log file: $LOG_FILE"

log_message "=== Script completed ==="
