#!/bin/sh
find . -name "*.jo" | xargs dart run bin/joc.dart -v
