
TARFILE = ../coords-deposit-$(shell date +'%Y-%m-%d').tar.gz

# For building on my office desktop
# Rscript = ~/R/r-devel-vecpat/BUILD/bin/Rscript
# Rscript = ~/R/r-devel/BUILD/bin/Rscript
# Rscript = Rscript

# For building in Docker container
Rscript = Rscript

%.xml: %.cml %.bib
	# Protect HTML special chars in R code chunks
	$(Rscript) -e 't <- readLines("$*.cml"); writeLines(gsub("str>", "strong>", gsub("<rcode([^>]*)>", "<rcode\\1><![CDATA[", gsub("</rcode>", "]]></rcode>", t))), "$*-protected.xml")'
	$(Rscript) toc.R $*-protected.xml
	$(Rscript) bib.R $*-toc.xml
	$(Rscript) foot.R $*-bib.xml

%.Rhtml : %.xml
	# Transform to .Rhtml
	xsltproc knitr.xsl $*.xml > $*.Rhtml

%.html : %.Rhtml
	# Use knitr to produce HTML
	$(Rscript) knit.R $*.Rhtml

docker:
	cp ../../gridGeometry_0.3-1.tar.gz .
	sudo docker build -t pmur002/coords-report .
	sudo docker run -v $(shell pwd):/home/work/ -w /home/work --rm pmur002/coords-report make coords.html

web:
	make docker
	cp -r ../coords-report/* ~/Web/Reports/Geometry/coords/

zip:
	make docker
	tar zcvf $(TARFILE) ./*
