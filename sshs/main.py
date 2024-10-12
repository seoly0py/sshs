import paramiko
import os

# SSH config 파일 경로
ssh_config_path = os.path.expanduser("~/.ssh/config")


def read_ssh_config():
    hosts = []
    if os.path.exists(ssh_config_path):
        with open(ssh_config_path, 'r') as f:
            lines = f.readlines()
            for line in lines:
                if line.strip().startswith('Host '):
                    host = line.split()[1]
                    hosts.append(host)
    return hosts


def connect_ssh(host):
    print(f"Connecting to {host}...")
    os.system(f"ssh {host}")


def main():
    hosts = read_ssh_config()
    if not hosts:
        print("No hosts found in SSH config.")
        return

    for idx, host in enumerate(hosts, 1):
        print(f"{idx}. {host}")

    try:
        choice = int(input("Select a host by number: "))
        if 1 <= choice <= len(hosts):
            connect_ssh(hosts[choice - 1])
        else:
            print("Invalid selection.")
    except ValueError:
        print("Please enter a valid number.")


if __name__ == "__main__":
    main()
