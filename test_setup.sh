#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
JSON_SERVER_PORT=3000
VADEN_BACKEND_PORT=8081
VADEN_LOG_FILE="vaden_backend.log"

# --- Start JSON Server ---
echo "Starting JSON Server..."
python json_server_controller.py start &
JSON_SERVER_PID=$!
# Give JSON server a moment to start
sleep 3

# --- Start Vaden Backend ---
echo "Starting Vaden Backend..."
cd dart_Vaden
dart run bin/server.dart > "../$VADEN_LOG_FILE" 2>&1 &
VADEN_BACKEND_PID=$!
cd ..
# Give Vaden backend a moment to start
sleep 10 # Increased sleep time

echo "Vaden Backend Log:"
cat "$VADEN_LOG_FILE"

# --- Test Vaden Backend Proxy to JSON Server ---
echo "Testing Vaden Backend proxy to JSON Server..."
response=$(curl -s http://localhost:${VADEN_BACKEND_PORT}/json-proxy/clients)

if echo "$response" | grep -q "Client A"; then
  echo "Test successful: Received expected data from JSON server via Vaden backend."
  echo "Response: $response"
else
  echo "Test failed: Did not receive expected data from JSON server via Vaden backend."
  echo "Response: $response"
  echo "Vaden Backend Log (again, for context of failure):"
  cat "$VADEN_LOG_FILE"
  # Clean up before exiting on failure
  echo "Cleaning up..."
  kill $JSON_SERVER_PID
  kill $VADEN_BACKEND_PID
  exit 1
fi

# --- Cleanup ---
echo "Cleaning up..."
kill $JSON_SERVER_PID
kill $VADEN_BACKEND_PID

echo "All services stopped and test completed."