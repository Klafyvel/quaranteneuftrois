JULIA=$(shell which julia)

build:
	${JULIA} --project generate.jl
	mkdir -p __site
	cp -r assets __site/
	cp index.html __site/

publish: build
	git -C __site/ commit -a -m "Automatic website build from Makefile."
	git -C __site/ push

gh-pages-in:
	git worktree add __site/ gh-pages

gh-pages-out:
	git worktree remove __site/
	git worktree prune

clean:
	rm -r __site/

.PHONY: clean build gh-pages-in gh-pages-out publish
