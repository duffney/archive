#!/bin/bash


if ! ansible-inventory -i $1 --graph; then
  echo "failed"
fi

ansible-playbook -i $1 site.yml
