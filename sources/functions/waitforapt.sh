#!/bin/bash

function waitforapt {
  while sudo fuser /var/{lib/{dpkg,apt/lists},cache/apt/archives}/lock >/dev/null 2>&1; do
    echo "waiting for apt locks"
    echo "waiting for apt locks" >> "${SEEDIT_LOG}" 2>&1;
    sleep 1
  done
}
