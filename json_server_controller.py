
import subprocess
import os
import signal
import time

class JsonServerController:
    def __init__(self, db_path='db.json', port=3000):
        self.db_path = db_path
        self.port = port
        self.process = None
        self.log_file = 'json_server.log'

    def start(self):
        if self.process:
            print("JSON server is already running.")
            return

        command = ["json-server", "--watch", self.db_path, "--port", str(self.port)]
        print(f"Starting JSON server with command: {' '.join(command)}")
        try:
            # Use preexec_fn to make the child process a process group leader
            # This allows killing the entire group later
            self.process = subprocess.Popen(
                command,
                stdout=open(self.log_file, 'w'),
                stderr=subprocess.STDOUT,
                preexec_fn=os.setsid
            )
            print(f"JSON server started with PID: {self.process.pid}")
            print(f"Logs are being written to {self.log_file}")
            time.sleep(2) # Give it a moment to start
            print(f"JSON server should be running at http://localhost:{self.port}")
        except FileNotFoundError:
            print("Error: json-server command not found. Make sure it's installed globally.")
            print("You might need to run: npm install -g json-server")
        except Exception as e:
            print(f"An error occurred while starting JSON server: {e}")

    def stop(self):
        if self.process is None:
            print("JSON server is not running.")
            return

        print(f"Stopping JSON server with PID: {self.process.pid}")
        try:
            # Send SIGTERM to the process group
            os.killpg(os.getpgid(self.process.pid), signal.SIGTERM)
            self.process.wait(timeout=5) # Wait for the process to terminate
            print("JSON server stopped.")
        except subprocess.TimeoutExpired:
            print("JSON server did not terminate gracefully. Sending SIGKILL.")
            os.killpg(os.getpgid(self.process.pid), signal.SIGKILL)
            self.process.wait()
            print("JSON server forcefully stopped.")
        except ProcessLookupError:
            print("JSON server process not found (already stopped?).")
        except Exception as e:
            print(f"An error occurred while stopping JSON server: {e}")
        finally:
            self.process = None

if __name__ == "__main__":
    controller = JsonServerController()

    # Example usage:
    # To start the server:
    # controller.start()

    # To stop the server:
    # controller.stop()

    # You can add command-line argument parsing here for more flexibility
    import sys
    if len(sys.argv) > 1:
        action = sys.argv[1]
        if action == "start":
            controller.start()
        elif action == "stop":
            controller.stop()
        else:
            print("Usage: python json_server_controller.py [start|stop]")
    else:
        print("Usage: python json_server_controller.py [start|stop]")
        print("No action specified. Starting server for 10 seconds as an example.")
        controller.start()
        time.sleep(10)
        controller.stop()
