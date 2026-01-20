# Live integration test for git clone with specific revision
#
# SKIPPED: GitHub doesn't support cloning arbitrary commits via --revision.
# Error: "fatal: remote error: upload-pack: not our ref <sha>"
# This is a GitHub server limitation, not a git client limitation.
#
# To support revision-based dependencies, implementation needs to:
# 1. Clone a branch: git clone --branch main <url> <path>
# 2. Checkout the commit: cd <path> && git checkout <revision>
#
# TODO: Implement two-step revision support in Phase 3 (optional)

test-git-dependency-live-revision:
	@echo "SKIPPED: GitHub doesn't support --revision cloning (server limitation)"
