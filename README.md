# Set up

Import the PGP key of the repository:
```
curl -fsSL TODO | sudo gpg --dearmor -o /etc/apt/keyrings/tmio.gpg
```

Add this repository to your repositories:
```
echo "deb [arch=all signed-by=/etc/apt/keyrings/tmio.gpg] TODO/repository stable main" | sudo tee /etc/apt/sources.list.d/tmio.list
```

Update:
```
sudo apt-get update
```

Install tuweni:
```
sudo apt-get install tuweni
```

