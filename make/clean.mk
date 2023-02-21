# Copyright (C) 2012-2020 SUSE Software Solutions Germany GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
#
# Cleanup for DAPS
#
# Please submit feedback or patches to
# <fsundermeyer at opensuse dot org>
#
.PHONY: clean
clean:
	rm -rf $(PROFILE_PARENT_DIR)
	rm -rf $(TMP_DIR)
	rm -rf $(ADOC_RESULT_DIR)
	rm -rf $(ASSEMBLY_RESULT_DIR)
	@ccecho "info" "Successfully removed all profiled and temporary files."

.PHONY: clean-images
clean-images:
	find $(IMG_GENDIR) -type f 2>/dev/null | xargs rm -f
	@ccecho "info" "Successfully removed all generated images."

.PHONY: clean-package
clean-package:
	rm -rf $(PACK_DIR)
	@ccecho "info" "Successfully removed all generated package data for $(notdir $(DOCCONF))"

.PHONY: clean-results
clean-results:
	rm -rf $(RESULT_DIR)
	@ccecho "info" "Successfully removed all generated books for $(notdir $(DOCCONF))"

.PHONY: clean-all real-clean
clean-all real-clean:
	rm -rf $(BUILD_DIR)
	@ccecho "info" "Successfully removed all generated content"
