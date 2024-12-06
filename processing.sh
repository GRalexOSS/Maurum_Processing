conda activate qiime2-2021.4

qiime demux emp-paired --m-barcodes-file MBAnalysis_Aurumig_final.txt --m-barcodes-column 'BarcodeSequence' --i-seqs ../import/paired-end-sequences.qza --p-rev-comp-barcodes --p-rev-comp-mapping-barcodes --output-dir aurumig_demux

qiime demux summarize --i-data aurumig_demux/per_sample_sequences.qza --o-visualization aurumig_demux/demux.qzv

qiime dada2 denoise-paired --i-demultiplexed-seqs aurumig_demux/per_sample_sequences.qza --p-trunc-len-f 151 --p-trunc-len-r 151 --p-trim-left-f 19 --p-trim-left-r 19 --output-dir aurumig_dada2-results

qiime metadata tabulate --m-input-file aurumig_dada2-results/denoising_stats.qza --o-visualization aurumig_dada2-results/denoising_stats.qzv

qiime feature-table filter-samples --i-table aurumig_dada2-results/table.qza --m-metadata-file MBAnalysis_Aurumig_final.txt --o-filtered-table aurumig_filtered_table.qza

qiime feature-table summarize --i-table aurumig_dada2-results/table.qza --o-visualization aurumig_dada2-results/table.qzv --m-sample-metadata-file MBAnalysis_Aurumig_final.txt

qiime fragment-insertion sepp --i-representative-sequences aurumig_dada2-results/representative_sequences.qza --i-reference-database ../sepp-refs-silva-128.qza --o-tree aurumig_insertion-tree-sepp.qza --o-placements aurumig_insertion-placements-sepp.qza

qiime fragment-insertion filter-features --i-table aurumig_filtered_table.qza --i-tree aurumig_insertion-tree-sepp.qza --o-filtered-table aurumig_filtered-table-sepp.qza --o-removed-table aurumig_removed-table-sepp.qza

qiime feature-classifier classify-sklearn --i-classifier ../silva-138-99-515-806-nb-classifier.qza --i-reads aurumig_dada2-results/representative_sequences.qza --output-dir aurumig_silva-classified

qiime metadata tabulate --m-input-file aurumig_silva-classified/classification.qza --o-visualization aurumig_silva-classified/classification.qzv

qiime taxa filter-table --i-table aurumig_filtered-table-sepp.qza --i-taxonomy aurumig_silva-classified/classification.qza --p-exclude mitochondria,chloroplast --o-filtered-table aurumig_noMito_noChloro-filtered-table.qza

qiime feature-table summarize --i-table aurumig_noMito_noChloro-filtered-table.qza --o-visualization aurumig_noMito_noChloro-filtered-table.qzv

qiime taxa barplot --i-table aurumig_noMito_noChloro-filtered-table.qza --i-taxonomy aurumig_silva-classified/classification.qza --m-metadata-file MBAnalysis_Aurumig_final.txt --o-visualization aurumig_taxa_plot.qzv

qiime alignment mafft --i-sequences aurumig_dada2-results/representative_sequences.qza --o-alignment aurumig_aligned-rep-seqs.qza

qiime alignment mask --i-alignment aurumig_aligned-rep-seqs.qza --o-masked-alignment aurumig_masked-aligned-rep-seqs.qza

qiime phylogeny fasttree --i-alignment aurumig_masked-aligned-rep-seqs.qza --o-tree aurumig_unrooted-tree.qza

qiime phylogeny midpoint-root --i-tree aurumig_unrooted-tree.qza --o-rooted-tree aurumig_rooted-tree.qza

qiime diversity alpha-rarefaction --i-table aurumig_dada2-results/table.qza --i-phylogeny aurumig_rooted-tree.qza --p-max-depth 4500 --m-metadata-file MBAnalysis_Aurumig_final.txt --o-visualization aurumig_alpha-rarefaction.qzv

qiime diversity alpha-rarefaction --i-table aurumig_noMito_noChloro-filtered-table.qza --i-phylogeny aurumig_insertion-tree-sepp.qza --o-visualization aurumig_rarefied-viz.qzv --p-max-depth 4500

qiime diversity core-metrics-phylogenetic --i-phylogeny aurumig_insertion-tree-sepp.qza --i-table aurumig_noMito_noChloro-filtered-table.qza --p-sampling-depth 1500 --m-metadata-file MBAnalysis_Aurumig_final.txt --output-dir aurumig_core-diversity-results

qiime taxa barplot --i-table aurumig_core-diversity-results/rarefied_table.qza --m-metadata-file MBAnalysis_Aurumig_final.txt --i-taxonomy aurumig_silva-classified/classification.qza --o-visualization aurumig_taxa_plot_post_rarefaction.qzv

