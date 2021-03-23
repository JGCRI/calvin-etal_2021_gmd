[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4631131.svg)](https://doi.org/10.5281/zenodo.4631131)


# calvin-etal_2021_gmd
**Modeling Land Use and Land Cover Change: Using a Hindcast to Estimate Economic Parameters in gcamland v2.0**

Katherine V. Calvin<sup> 1\*</sup>, Abigail Snyder<sup> 1</sup>, Xin Zhao<sup> 1</sup>, Marshall Wise<sup> 1</sup>

<sup>1 </sup> Joint Global Change Research Institute, Pacific Northwest National Laboratory, College Park, MD, 20740, USA  
\* corresponding author: katherine.calvin@pnnl.gov

## Abstract
The world has experienced a vast increase in agricultural production since the middle of the last century; however, agricultural land area has expanded at a lower rate than production. Future changes in land use and cover have important implications not only for agriculture but for energy, water use, and climate. However, these future changes are driven by a complex combination of uncertain socioeconomic, technological, and other factors. Estimates of future land use and land cover differ significantly across economic models of agricultural production and efforts to evaluate these economic models over history have been limited. In this study, we use an economic model of land use and land cover change, gcamland, to systematically explore a large set of model parameter perturbations and alternate methods for forming expectations about uncertain crop yields and prices. We run gcamland simulations with these parameter sets over the historical period in the United States to quantify land use and land cover, determine how well the model reproduces observations, and to identify parameter combinations that improve the model. We find that an adaptive expectation approach minimizes the error between simulated outputs and observations, with parameters that suggest that for most crops landowners put a significant weight on previous information. Interestingly, for corn, where ethanol policies have led to a rapid growth in demand, the resulting parameters show that a larger weight is placed on more recent information. We examine the change in model parameters as the metric of model error changes, finding that the measure of model fitness affects the choice of parameter sets. Finally, we identify how the methodology and results used in this study could be used in future studies by GCAM or other models.

## Journal reference
Calvin, K. V., Snyder, A., Zhao, X., and Wise, M.: Modeling Land Use and Land Cover Change: Using a Hindcast to Estimate Economic Parameters in gcamland v2.0, Geosci. Model Dev. Discuss. [preprint], https://doi.org/10.5194/gmd-2020-338, in review, 2020.

## Data reference
### Input data
All `gcamland` input data is contained in the `gcamland` repository. See data in v2.0 as cited in the contributing models section below.

### Output data
Katherine V. Calvin, Abigail Snyder, Xin Zhao, & Marshall Wise. (2021). DATASET: Modeling Land Use and Land Cover Change: Using a Hindcast to Estimate Economic Parameters in gcamland v2.0 (Version v1.0) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.4630418  

## Contributing models
| Model | Version | Repository Link | DOI | Notes |
|-------|---------|-----------------|-----| ----- |
| `gcamland` | v2.0 | https://github.com/JGCRI/gcamland/releases/tag/v2.0 | http://doi.org/10.5281/zenodo.4071797 | General research in the paper |
| `gcamland` | NA | https://github.com/JGCRI/gcamland/commit/25e44761dc27aaaf79de444b7b212a8223a243e8 | NA | The large ensemble was created from one hash prior to the v2.0 release. The only difference between that hash and the final is that we renamed the expectation types to match the terminology in the paper. |

## Reproduce my experiement

Use the code in this repository to reproduce this experiment.

1. `run_scripts`:  Used to generate the large ensemble
2. `postprocessing_scripts`:  Used to combine outputs for use in figures. The outputs from these scripts have to go in the `1-data` directory with the correct names to be functional.  
3. `figures`:  Used to create all figures for the paper
