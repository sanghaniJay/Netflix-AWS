#!/bin/bash

yum update -y
yum install -y python3 python3-pip mariadb105

pip3 install flask pymysql

cat > /home/ec2-user/app.py << 'EOF'
from flask import Flask, jsonify

app = Flask(__name__)


@app.route('/')
def home():
    return "<h1>Netflix-Style App - Phase 1</h1><p>Single EC2 + RDS</p>"


@app.route('/catalog')
def catalog():
    return jsonify({
        "service": "catalog",
        "items": ["Movie A", "Movie B"]
    })


@app.route('/user')
def user():
    return jsonify({
        "service": "user",
        "status": "ok"
    })


@app.route('/health')
def health():
    return jsonify({
        "status": "ok",
        "phase": "1"
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF


sudo tee /etc/systemd/system/flaskapp.service << 'SVCEOF'
[Unit]
Description=Flask Workshop App
After=network.target

[Service]
User=root
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/app.py
Restart=always

[Install]
WantedBy=multi-user.target
SVCEOF


systemctl daemon-reload
systemctl enable flaskapp
systemctl start flaskapp
