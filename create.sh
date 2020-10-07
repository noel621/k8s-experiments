#!/bin/bash
PROVIDER=libvirt
vagrant up k8s-lb master-1 --provider $PROVIDER
vagrant up --provider $PROVIDER

