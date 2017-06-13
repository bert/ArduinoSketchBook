DIRS = \
	docs

.DEFAULT_GOAL := all

all: \
	$(html_TARGETS)
	target=`echo $@ | sed s/-recursive//`; \
	list='$(DIRS)'; for subdir in $$list; do \
		echo "Making $$target in $$subdir"; \
		cd $$subdir; \
		make; \
		cd ..; \
	done;

