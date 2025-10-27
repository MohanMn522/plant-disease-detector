#!/usr/bin/env python3
"""
Script to start the Plant Disease Detector backend server
"""

import os
import sys
import subprocess
import platform

def main():
    # Get the directory of this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    backend_dir = os.path.join(script_dir, 'backend')
    
    # Check if backend directory exists
    if not os.path.exists(backend_dir):
        print("❌ Backend directory not found!")
        return 1
    
    # Change to backend directory
    os.chdir(backend_dir)
    
    # Check if virtual environment exists
    venv_path = os.path.join(backend_dir, 'venv')
    if not os.path.exists(venv_path):
        print("📦 Creating virtual environment...")
        subprocess.run([sys.executable, '-m', 'venv', 'venv'], check=True)
    
    # Activate virtual environment and install dependencies
    if platform.system() == "Windows":
        activate_script = os.path.join(venv_path, 'Scripts', 'activate.bat')
        pip_path = os.path.join(venv_path, 'Scripts', 'pip.exe')
        python_path = os.path.join(venv_path, 'Scripts', 'python.exe')
    else:
        activate_script = os.path.join(venv_path, 'bin', 'activate')
        pip_path = os.path.join(venv_path, 'bin', 'pip')
        python_path = os.path.join(venv_path, 'bin', 'python')
    
    print("📦 Installing dependencies...")
    subprocess.run([pip_path, 'install', '-r', 'requirements.txt'], check=True)
    
    print("🚀 Starting backend server...")
    print("📍 Server will be available at: http://localhost:8000")
    print("📚 API documentation: http://localhost:8000/docs")
    print("🛑 Press Ctrl+C to stop the server")
    print("-" * 50)
    
    # Start the server
    try:
        subprocess.run([python_path, '-m', 'uvicorn', 'app.main:app', '--reload', '--host', '0.0.0.0', '--port', '8000'], check=True)
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error starting server: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())


