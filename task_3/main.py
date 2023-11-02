import pysam
import numpy as np
import pandas as pd
import argparse
import sys
import logging

logging.basicConfig(
    format='%(asctime)s %(levelname)-8s %(message)s',
    level=logging.DEBUG,
    datefmt='%Y-%m-%d %H:%M:%S'
)


def main():
    parser = argparse.ArgumentParser(description='Identification of reference and alternative alleles.')

    parser.add_argument('-i', '--input', help='input file path')
    parser.add_argument('-r', '--reference', help='reference file path')
    parser.add_argument('-o', '--output', default='.', help='output folder')

    args = parser.parse_args()

    if not args.input:
        return logging.error('No input file provided')

    if not args.reference:
        return logging.error('No reference file provided')
    
    logging.info("Reading input file...")
    data = pd.read_csv(args.input, sep='\t')

    data= data[data['chromosome']!=23]
    data = data.drop('GB37_position', axis=1)
    data['chromosome'] = data['chromosome'].astype(str)
    data['rs#'] = data['rs#'].astype(str)
    data['CHROM'] =  'chr'+data['chromosome']
    data = data.drop('chromosome', axis=1)
    data['ID'] =  'rs'+data['rs#']
    data = data.drop('rs#', axis=1)
    data = data.rename(columns={'GB38_position': 'POS'})

    fastafile = pysam.FastaFile(args.reference)
    logging.info("Execution of the algorithm...")
    data['REF'] = np.zeros(len(data))
    for i in range(len(data)):
        data['REF'][i] = fastafile.fetch(data['CHROM'][i], data['POS'][i]-1, data['POS'][i])
        
        
    data['ALT'] = np.zeros(len(data))
    for i in range(len(data)):
        if (data['REF'][i] == data['allele1'][i]) and (data['REF'][i] == data['allele2'][i]):
            data['ALT'][i] = data['REF'][i]
        elif (data['REF'][i] != data['allele1'][i]) and (data['REF'][i] == data['allele2'][i]):
            data['ALT'][i] = data['allele1'][i]
        elif (data['REF'][i] == data['allele1'][i]) and (data['REF'][i] != data['allele2'][i]):
            data['ALT'][i] = data['allele2'][i]
        else:
            data['ALT'][i] = ', '.join((data['allele1'][i], data['allele2'][i]))

    data = data.drop(['allele1', 'allele2'], axis=1)
    data = data.reindex(columns=['CHROM', 'POS', 'ID', 'REF', 'ALT'])
    logging.info("Сreating an output file...")
    with open(args.output + '/FP_SNPs_10k_GB38_twoAllelsFormat.tsv', 'w') as f:
        f.write(data.to_csv())
    

if __name__ == "__main__":
    main()
