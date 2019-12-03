package: defaults-root6
version: v1
disable:
  - arrow
env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++17"
  CFLAGS: "-fPIC -g -O2"
  CXXSTD: "17"
  CMAKE_BUILD_TYPE: "RELWITHDEBINFO"
overrides:
  ROOT:
    source: https://github.com/root-project/root
    version: "%(tag_basename)s"
    tag: v6-16-00
  AliRoot:
    version: "%(tag_basename)s_ROOT6"
    tag: v5-09-51
  AliPhysics:
    version: "%(tag_basename)s_ROOT6"
    tag: v5-09-51-01
---
