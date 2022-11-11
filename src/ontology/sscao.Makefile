## Customize Makefile settings for sscao
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

SCATLAS_KEEPRELATIONS= ../curation/scatlas_relations.txt

components/fbbt_seed_extract.sparql: ../curation/scatlas_seed.txt
	sh ../scripts/generate_sparql_subclass_query.sh $< $@

components/fbbt_simple_seed.txt: components/fbbt_seed_extract.sparql ../curation/scatlas_seed.txt $(SCATLAS_KEEPRELATIONS)
	$(ROBOT) query --input imports/fbbt_import.owl --query components/fbbt_seed_extract.sparql $@.tmp.txt && \
	cat ../curation/scatlas_seed.txt $(SCATLAS_KEEPRELATIONS) $@.tmp.txt | sort | uniq > $@  && rm $@.tmp.txt

components/fbbt.owl: imports/fbbt_import.owl components/fbbt_simple_seed.txt
	java -jar ../../robot.jar extract --method subset --input $< --term-file components/fbbt_simple_seed.txt --output $@.tmp.owl
	$(ROBOT) annotate --input $@.tmp.owl --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@ && rm $@.tmp.owl
