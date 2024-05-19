#!/usr/bin/env Rscript
#SBATCH --mem 80G
#SBATCH -J psu

library(dplyr)
library(data.table)
library(stringr)
library(Seurat)

size_bulk = 100
num_bulk = 200


#### verify that @data slot is updated 
seurat_path = '/stg3/data1/eunice/Projects/Entropy/MethodDevepment_AllDefs_230716/script/07_AllDisease/00_data/00_scAlzheimers/seurat.rds'
seurat = readRDS(seurat_path) %>% 
    NormalizeData()

##### set conditions
conditions = 'Diagnosis'
cell_ = 'Cell.Type'
##### split by conditions that are biologically relevant 
samples = seurat@meta.data[[conditions]] %>% unique
names(samples) = samples


parent='../alzheimers_pseudobulks'
dir.create(parent)
## save barcodes 
o = paste0(parent, '/00_barcodes')
dir.create(o)

n = paste0(parent, '/01_pseudobulk_counts')
dir.create(n)

# cells = seurat@meta.data[[cell.type]] %>% unique %>% as.character
# names(cells) = cells

samples %>% 
    lapply(function(sample){
        cells = subset(seurat, subset = Diagnosis == sample)@meta.data[[cell_]] %>% unique
        cells = cells[!is.na(cells)]
        names(cells) = cells
        cells %>% 
            lapply(function(celltype){
                print(sample)
                print(celltype)
                
                ##### get all cells that fit condition and celltype
                s = subset(seurat, subset = seurat[[cell_]] == celltype & Diagnosis == sample)
                s$barcode = s@meta.data %>% row.names()
                s = s@assays$ATAC@data


                ##### split by pseudobulk assignment
                m_barcodes = size_bulk * num_bulk
                if (length(colnames(s)) < m_barcodes){
                    num_bulk_new = floor(length(colnames(s)) / size_bulk )
                    barcodes = (colnames(s) %>% sample())[1:(size_bulk * num_bulk_new)] %>% unlist %>% unname 
                }else{
                    barcodes = (colnames(s) %>% sample())[1:(size_bulk * num_bulk)] %>% unlist %>% unname 
                }
               barcodes = split(barcodes, ceiling(seq_along(barcodes)/size_bulk)) 
               

               ###### for each pseudobulk, aggregate counts and write to bedgraph file
               names(barcodes) %>% 
                lapply(function(x) {
                    print(x)
                    name = paste0(sample, '-', celltype, '_', x)
                    barcodes[[x ]] %>% list %>% fwrite(paste0(o,'/', name, '.txt'))

                    c = s[,barcodes[[x]]]
                    #1:5])
                    c = c%>% rowSums() %>% 
                        as.data.frame
                    c$coord = row.names(c)
                    c %>% 
                        tidyr::separate(coord, c('chr','start','end')) %>% 
                        dplyr::select(2,3,4,1) %>%
                    write.table(., file=paste0(n, '/', name, '.bdg'), quote=F, sep="\t", row.names=F, col.names=F)
                    })
                
               
            })
    })





