#
# Ole Troan, ot@cisco.com
# September 2010

XML2RFC:=xml2rfc

all:	drafts
drafts: draft-troan-6man-universal-ra-option

draft-troan-6man-universal-ra-option: draft-troan-6man-universal-ra-option.xml
	$(XML2RFC) $< $@-02.txt

.PHONY: clean drafts all
clean:
	$(RM) *.txt
