#######################################################################################################
# Author: Michel Szklo
# April 2022
# 
# This scripts runs reduced form graphs for all outcomes
#
#
#######################################################################################################

# 0. Set-up
# =================================================================

rm(list=ls())

# packages
packages<-c('readr',
            'tidyverse',
            'dplyr',
            'RCurl',
            'tidyr',
            'scales',
            'RColorBrewer',
            'ggplot2',
            'xlsx',
            'stringdist',
            'textclean',
            'readstata13',
            'lfe',
            'fastDummies',
            'purrr',
            'boot',
            'broom',
            'modelsummary',
            'ggsci')
to_install<-packages[!(packages %in% installed.packages()[,"Package"])]
if(length(to_install)>0) install.packages(to_install)

lapply(packages,require,character.only=TRUE)


options(digits = 15)


# SET PATH FOR EC 29-2000 ON YOUR COMPUTER
# ------------------------------------

dir <- "C:/Users/Michel/Google Drive/DOUTORADO FGV/Artigos/EC 29-2000/"

# ------------------------------------


# 1. Load data, folder and heterogeneity set up
# =================================================================
load(paste0(dir,"regs.RData"))

df_low_ineq <- df_below
df_high_ineq <- df_above

# yearly_folder <- "yearly_reduced_form_dist_ec29_elect/"
# 
# dir.create(paste0(dir,main_folder,yearly_folder), showWarnings = FALSE)

df1 <- df_low_ineq
df1_name <- "1. Below Target"
df2 <- df_high_ineq
df2_name <- "2. Above Target"

gf_name <- "_abovebelow"



# 2. Spending
# =================================================================



var_map <- rbind(cbind('finbra_reccorr_pcapita','Total Revenue per capita (2010 R$)'),
                 
                 cbind('finbra_desp_o_pcapita','Total Spending per capita (2010 R$)'),
                 cbind('finbra_desp_pessoal_pcapita','Human Resources Spending per capita (2010 R$)'),
                 cbind('finbra_desp_investimento_pcapita','Investment Spending per capita (2010 R$)'),
                 cbind('finbra_desp_outros_nature_pcapita','Other Spending per capita (2010 R$)'),
                 
                 cbind('finbra_desp_saude_san_pcapita','Health and Sanitation Spending per capita (2010 R$)'),
                 cbind('finbra_desp_nao_saude_pcapita','All Other Spending per capita (2010 R$)'),
                 cbind('finbra_desp_transporte_pcapita','Transport Spending per capita (2010 R$)'),
                 cbind('finbra_desp_educ_cultura_pcapita','Education and Culture Spending per capita (2010 R$)'),
                 cbind('finbra_desp_hab_urb_pcapita','Housing and Urban Spending per capita (2010 R$)'),
                 cbind('finbra_desp_assist_prev_pcapita','Social Assistance Spending per capita (2010 R$)'),
                 cbind('finbra_desp_outros_area_pcapita','Other Areas Spending per capita (2010 R$)'),
                 
                 cbind('siops_despsaude_pcapita','Health Spending per capita - Total (2010 R$)'),
                 cbind('siops_desprecpropriosaude_pcapita','Health Spending per capita - Own Resources (2010 R$)'),
                 cbind('siops_despexrecproprio_pcapita','Health Spending per capita - Transfers (2010 R$)'),
                 cbind('siops_desppessoal_pcapita','Health Spending per capita - Human Resources (2010 R$)'),
                 cbind('siops_despinvest_pcapita','Health Spending per capita - Investiment (2010 R$)'),
                 cbind('siops_despservicoster_pcapita','Health Spending per capita - 3rd parties services (2010 R$)'),
                 cbind('siops_despoutros_pcapita','Health Spending per capita - other expenditures (2010 R$)'))

# # figure A1

for (i in seq(1,2,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.8,0.4,0.2,paste0("A1",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
  
}

# # figure A2

for (i in seq(3,5,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-1,0.4,0.2,paste0("A2",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}

# figure A3

for (i in seq(6,12,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-2.4,0.4,0.2,paste0("A3",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}

# figure 6 (ex 9)

for (i in c(6,seq(13,15,1))){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,0.4,0.1,paste0("6",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}


# figure 7 (ex 10)

for (i in seq(16,19,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,1,0.2,paste0("7",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}


# 3. Coverage and Infra
# =================================================================

var_map <- rbind(cbind('ACS_popprop','Population covered (share) by Community Health Agents'),
                 cbind('eSF_popprop','Population covered (share) by Family Health Agents'),
                 cbind('siab_accomp_especif_pcapita','N. of People Visited by Primary Care Agents (per capita)'),
                 cbind('siab_accomp_especif_pacs_pcapita','N. of People Visited by Community Health Agents (per capita)'),
                 cbind('siab_accomp_especif_psf_pcapita','N. of People Visited by Family Health Agents (per capita)'),
                 cbind('siab_visit_cons_pcapita','N. of Household Visits and Appointments (per capita)'),
                 cbind('siab_visit_cons_pacs_pcapita','N. of Household Visits and Appointments from Community Health Agents (per capita)'),
                 cbind('siab_visit_cons_psf_pcapita','N. of Household Visits and Appointments from Family Health Agents (per capita)'),
                 
                 cbind('ams_hr_superior_pcapita','N. of Doctors (per capita*1000)'),
                 cbind('ams_hr_technician_pcapita','N. of Nurses (per capita*1000)'),
                 cbind('ams_hr_elementary_pcapita','N. of Nursing Assistants (per capita*1000)'),
                 cbind('ams_hr_admin_pcapita','N. of Administrative Professionals (per capita*1000)'),
                 
                 cbind('ams_hospital_mun_pcapita','N. of Municipal Hospitals (per capita*1000)'),
                 cbind('ams_hospital_nmun_pcapita','N. of Federal and State Hospitals (per capita*1000)'),
                 cbind('ams_hospital_pvt_pcapita','N. of Private Hospitals (per capita*1000)'),
                 
                 
                 # cbind('siab_visit_cha_pcapita','N. of Household Visits (per capita)'),
                 # cbind('siab_visit_cha_pacs_pcapita','N. of Household Visits by Community Health Agents (per capita)'),
                 # cbind('siab_visit_cha_psf_pcapita','N. of Household Visits by Family Health Agents (per capita)'),
                 # cbind('siab_cons_especif_pcapita','N. of Appointments (per capita)'),
                 # cbind('siab_cons_especif_pacs_pcapita','N. of Appointments from Community Health Program (per capita)'),
                 # cbind('siab_cons_especif_psf_pcapita','N. of Appointments from Family Health Program (per capita)'),
                 
                 cbind('sia_ncnes_amb_mun_pcapita','N. of Health Facilities with Ambulatory Service (per capita*1000)'),
                 cbind('sia_ncnes_acs_pcapita','N. of Health Facilities with Ambulatory Service and ACS Teams (per capita*1000)'),
                 cbind('sia_ncnes_medcom_pcapita','N. of Health Facilities with Ambulatory Service and Community Doctors (per capita*1000)'),
                 cbind('sia_ncnes_enfacs_pcapita','N. of Health Facilities with Ambulatory Service and ACS Nurses (per capita*1000)'),
                 cbind('sia_ncnes_psf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Teams (per capita*1000)'),
                 cbind('sia_ncnes_medpsf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Doctors (per capita*1000)'),
                 cbind('sia_ncnes_enfpsf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Nurses (per capita*1000)'),
                 cbind('sia_ncnes_outpsf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Nursing Assistants (per capita*1000)')
)


# figure 8 (ex 11)

for (i in seq(1,2,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.1,0.1,0.02,paste0("8",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}


# figure 9 (ex 12)
for (i in seq(3,8,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.6,0.6,0.1,paste0("9",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}


# figure 10
for (i in seq(9,12,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1 %>% mutate(pre_99_dist_ec29_baseline=0),df1_name,df2 %>% mutate(pre_99_dist_ec29_baseline=0),df2_name,3,1998,-0.2,0.2,0.05,paste0("10",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}



# figure 11
for (i in seq(13,15,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1 %>% mutate(pre_99_dist_ec29_baseline=0),df1_name,df2 %>% mutate(pre_99_dist_ec29_baseline=0),df2_name,3,1998,-0.8,0.8,0.2,paste0("11",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}

# figure 11
for (i in seq(16,16,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.8,0.8,0.2,paste0("11",gf_name),below = below,weight = "peso_eq",year_cap = 2007) # ec29baseline
}


# figure 12 (ex 13)
for (i in seq(17,23,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,0.4,0.05,paste0("12",gf_name),below = below,weight = "peso_eq",year_cap = 2007) # ec29baseline
}





# 4. Access and Production
# =================================================================

var_map <- rbind(cbind('birth_prenat_ig','Prenatal Visits - Ignored'),
                 cbind('birth_prenat_0','Prenatal Visits None'),
                 cbind('birth_prenat_1_6','Prenatal Visits 1-6'),
                 cbind('birth_prenat_7_plus','Prenatal Visits 7+'),
                 cbind('sia_pcapita','N. Outpatient Procedures (per capita)'),
                 cbind('sia_ab_pcapita','N. Primary Care Outpatient Procedures (per capita)'),
                 cbind('sia_nprod_amb_lc_mun_pcapita','N. Low & Mid Complexity Outpatient Procedures (per capita)'),
                 cbind('sia_nprod_amb_hc_mun_pcapita','N. High Complexity Outpatient Procedures (per capita)'),
                 cbind('sia_nprod_low_skill_mun_pcapita','N. Outpatient Procedures by Low Skilled Workers (per capita)'),
                 cbind('sia_nprod_med_skill_mun_pcapita','N. Outpatient procedures by Mid Skilled Workers (per capita)')
                 
)



# figure 13 (ex 14)
for (i in seq(1,4,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.5,0.4,0.05,paste0("13",gf_name),below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
}


# figure 14 (ex 15)
for (i in seq(5,6,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,0.1,0.05,paste0("14",gf_name),below = below,weight = "peso_eq",year_cap = 2010) # ec29baseline
}

for (i in seq(7,10,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,0.1,0.05,paste0("14",gf_name),below = below,weight = "peso_eq",year_cap = 2007) # ec29baseline
}



# 7. Hospitalization
# =================================================================

var_map <- rbind(cbind('tx_sih_infant','Infant Hospitalization Rate (pop 0-1y * 1000)'),
                 cbind('tx_sih_infant_icsap','Infant Hospitalization Rate - APC (pop 0-1y * 1000)'),
                 cbind('tx_sih_infant_nicsap','Infant Hospitalization Rate - non-APC (pop 0-1y * 1000)'),
                 cbind('tx_sih_maternal','Maternal Hospitalization Rate (women 10-49y * 1000)')
)


for (i in seq(1,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,0.25,0.05,paste0("19",gf_name),below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
}

for (i in seq(4,4,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,0.25,0.05,paste0("19",gf_name),below = below,weight = "peso_m",year_cap = 2010) # ec29baseline
}







# 6. IMR
# =================================================================

var_map <-  rbind(cbind('tx_mi','Infant Mortality Rate'),
                  cbind('tx_mi_icsap','Infant Mortality Rate - APC'),
                  cbind('tx_mi_nicsap','Infant Mortality Rate - non-APC'),
                  cbind('tx_mi_infec','Infant Mortality Rate - Infectious'),
                  cbind('tx_mi_resp','Infant Mortality Rate - Respiratory'),
                  cbind('tx_mi_perinat','Infant Mortality Rate - Perinatal'),
                  cbind('tx_mi_cong','Infant Mortality Rate - Congenital'),
                  cbind('tx_mi_ext','Infant Mortality Rate - External'),
                  cbind('tx_mi_nut','Infant Mortality Rate - Nutritional'),
                  cbind('tx_mi_out','Infant Mortality Rate - Other'),
                  cbind('tx_mi_illdef','Infant Mortality Rate - Ill-Defined'),
                  cbind('tx_mi_fet','Infant Mortality Rate - Fetal'),
                  cbind('tx_mi_24h','Infant Mortality Rate - Within 24h'),
                  cbind('tx_mi_27d','Infant Mortality Rate - 1 to 27 days'),
                  cbind('tx_mi_ano','Infant Mortality Rate - 27 days to 1 year'))


# figure 15 (ex 16)
# for (i in seq(1,3,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-20,10,5,"16",below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
# }

for (i in seq(1,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_imr_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.4,0.4,0.1,paste0("15",gf_name),below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
}


# figure 16 (ex 17)
# for (i in seq(12,15,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-10,10,5,"17",below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
# }

for (i in seq(12,15,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_imr_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.4,0.4,0.1,paste0("16",gf_name),below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
}


# figure 17 (ex 18)
# for (i in seq(4,11,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-10,10,5,"18",below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
# }

for (i in seq(4,11,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_imr_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.6,0.6,0.1,paste0("17",gf_name),below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
}




# 7. Fertility and Birth
# =================================================================

var_map <- rbind(cbind('birth_fertility','Fertility (N. of Births per 10-49y women)'),
                 cbind('birth_apgar1','Apgar 1'),
                 cbind('birth_apgar5','Apgar 5'),
                 cbind('birth_low_weight_2500g','Low Birth Weight (<2.5k)'),
                 cbind('birth_premature','Premature Birth'),
                 cbind('birth_sexratio',"Sex Ratio at Birth"))



# Figure 18 (ex 19)
for (i in c(1,seq(4,6,1))){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.2,0.2,0.05,paste0("18",gf_name),below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
}

for (i in seq(2,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_het(var,var_name,df1,df1_name,df2,df2_name,3,1998,-0.05,0.05,0.01,paste0("18",gf_name),below = below,weight = "peso_b",year_cap = 2010) # ec29baseline
}







