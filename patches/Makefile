
## additional of manpages generation
# define a new mansources to allow manpages to be generated without errors
MANSOURCES2   = $(CORESOURCES)
onlymanpages: manpages allchecks

manpages: man/apispec.txt $(GENDEPENDS)
	$(MAKE) buildmanpages2

MANPAGESDIR = $(OUTDIR)/man
MANPAGES    = $(MANSOURCES2:$(MANDIR)/%.txt=$(MANPAGESDIR)/%.3)
buildmanpages2: $(MANPAGES)

$(MANPAGESDIR)/%.3: $(MANDIR)/%.txt $(MANCOPYRIGHT) $(GENINCLUDE) $(GENDEPENDS)
	$(QUIET)$(MKDIR) $(MANPAGESDIR)
	$(ASCIIDOC) -b manpage $(ADOCOPTS) -d manpage -o $@ $<

# separate clean target
# to clean generated files from `make onlymanpages` use `make clean_onlymanpages`
# at the root directory of Vulkan-Docs
clean_onlymanpages:
	$(QUIET)$(RM) man/apispec.txt $(LOGFILE) man/[Vv][Kk]*.txt man/PFN*.txt
	$(QUIET)$(RMRF) $(MANPAGESDIR)
