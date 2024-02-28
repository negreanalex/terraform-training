#!/bin/bash
sudo su azureadmin
mkdir myagent && cd myagent
curl https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-linux-x64-3.234.0.tar.gz --output vsts-agent-linux.tar.gz
tar zxvf vsts-agent-linux.tar.gz
