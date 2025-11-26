## only home-manager setup

1. create user in remote server
2. add user to sudoers, and switc to user
3. install nix
4. ssh-keygen and obtain public key
5. edit secrets.nix and resign all secrets 
6. nix run github:serokell/deploy-rs -- .#hostname -s
