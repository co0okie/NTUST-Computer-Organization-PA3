IGNORE = $(wildcard Part[123]/tb_*.v)
V = $(filter-out $(IGNORE), $(wildcard Part[123]/*.v))

.PHONY: zip

zip: B11107051.zip

B11107051.zip: report/report.pdf $(V)
	rm -f $@;
	cp report/report.pdf B11107051.pdf;
	zip -r $@ $(V) B11107051.pdf;
	rm B11107051.pdf;

clean: 
	rm -rf B11107051.zip