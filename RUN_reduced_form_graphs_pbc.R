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


# 1. Load data
# =================================================================
load(paste0(dir,"regs_pbc.RData"))


df2 <- df

# 2. Spending
# =================================================================

outliers <- df %>% 
  mutate(s = log(finbra_desp_o_pcapita)) %>% 
  select(s,everything())

ndesv <- 5
x <- mean(outliers$s, na.rm = T)
sd <- sd(outliers$s, na.rm = T)
outliers <- outliers %>% 
  mutate(s1 = x - sd * ndesv,
         s2 = x + sd * ndesv) %>% 
  filter(s<=s1 | s>=s2) %>% 
  select(cod_mun) %>% 
  unique()

outliers <- outliers$cod_mun

df <- df %>% 
  filter(!(cod_mun %in% outliers))

# redefines folder
yearly_folder <- "regs_plots_pbc/fiscal_response/"

var_map1 <- rbind(cbind('finbra_recorc_pcapita','Total Revenue per capita (log)'),
                  cbind('finbra_desp_o_pcapita','Total Spending per capita (log)'),
                  
                  cbind('finbra_desp_saude_san_pcapita','Health and Sanitation Spending per capita (log)'),
                  cbind('finbra_desp_nao_saude_pcapita','Non-Health Spending per capita (log)'),
                  cbind('finbra_despsocial_pcapita','Non-Health Social Spending per capita (log)'),
                  cbind('finbra_desp_outros_area_pcapita','Non-Social Spending per capita (log)'),
                  
                  cbind('siops_despsaude_pcapita','Health Spending per capita - Total (log)'),
                  cbind('siops_desprecpropriosaude_pcapita','Health Spending per capita - Own Resources (log)'),
                  cbind('siops_despexrecproprio_pcapita','Health Spending per capita - Other Resources (log)'),
                  cbind('siops_desppessoal_pcapita','Health Spending per capita - Personnel (log)'),
                  cbind('siops_despinvest_pcapita','Health Spending per capita - Investiment (log)'),
                  cbind('siops_despservicoster_pcapita','Health Spending per capita - Outsourced (3rd parties services) (log)'),
                  cbind('siops_despoutros_pcapita','Health Spending per capita - Admin, Management, others (log)'))



# per capita level
var_map2 <- rbind(cbind('finbra_recorc_pcapita','Total Revenue per capita (2010 R$)'),
                  cbind('finbra_desp_o_pcapita','Total Spending per capita (2010 R$)'),
                  
                  cbind('finbra_desp_saude_san_pcapita','Health and Sanitation Spending per capita (2010 R$)'),
                  cbind('finbra_desp_nao_saude_pcapita','Non-Health Spending per capita (2010 R$)'),
                  cbind('finbra_despsocial_pcapita','Non-Health Social Spending per capita (2010 R$)'),
                  cbind('finbra_desp_outros_area_pcapita','Non-Social Spending per capita (2010 R$)'),
                  
                  cbind('siops_despsaude_pcapita','Health Spending per capita - Total (2010 R$)'),
                  cbind('siops_desprecpropriosaude_pcapita','Health Spending per capita - Own Resources (2010 R$)'),
                  cbind('siops_despexrecproprio_pcapita','Health Spending per capita - Other Resources (2010 R$)'),
                  cbind('siops_desppessoal_pcapita','Health Spending per capita - Personnel (2010 R$)'),
                  cbind('siops_despinvest_pcapita','Health Spending per capita - Investiment (2010 R$)'),
                  cbind('siops_despservicoster_pcapita','Health Spending per capita - Outsourced (3rd parties services) (2010 R$)'),
                  cbind('siops_despoutros_pcapita','Health Spending per capita - Admin, Management, others (2010 R$)'))


# continuous 1st vs 2nd

for (i in seq(1,2,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,1,1998,-2,3,0.5,paste0("1_terms_log_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
  
}


for (i in seq(3,6,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,1,1998,-2,3,0.5,paste0("1_terms_log_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
}

for (i in seq(3,3,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,1,1998,-3,9.25,1,paste0("1_terms_log2_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
}

for (i in seq(7,13,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,1,1998,-3,9.25,1,paste0("1_terms_log_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
}




# continuous 1st

for (i in seq(1,2,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),1,1998,-2,3,0.5,paste0("2_first_log_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
  
}


for (i in seq(3,6,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),1,1998,-2,3,0.5,paste0("2_first_log_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
}

for (i in seq(3,3,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),1,1998,-3,9.25,1,paste0("2_first_log_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
}

for (i in seq(7,13,1)){
  var <- var_map1[i,1]
  var_name <- var_map1[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),1,1998,-3,9.25,1,paste0("2_first_log_",i),weight = "peso_pop",year_cap = 2010,cont = 1) # ec29baseline
}




# 3. Access and Production
# =================================================================

df <- df2
# creating missing SIA variable
df <- df %>% 
  mutate(sia_nab_pcapita = sia_pcapita - sia_ab_pcapita)
yearly_folder <- "regs_plots_pbc/access_production/"

var_map <- rbind(cbind('ACS_popprop','Population covered (share) by Community Health Agents'),
                 cbind('eSF_popprop','Population covered (share) by Family Health Agents'),
                 cbind('siab_accomp_especif_pcapita','N. of People Visited by Primary Care Agents (per capita)'),
                 cbind('siab_accomp_especif_pacs_pcapita','N. of People Visited by Community Health Agents (per capita)'),
                 cbind('siab_accomp_especif_psf_pcapita','N. of People Visited by Family Health Agents (per capita)'),
                 cbind('siab_visit_cons_pcapita','N. of Household Visits and Appointments (per capita)'),
                 cbind('siab_visit_cons_pacs_pcapita','N. of Household Visits and Appointments from Community Health Agents (per capita)'),
                 cbind('siab_visit_cons_psf_pcapita','N. of Household Visits and Appointments from Family Health Agents (per capita)'),
                 
                 cbind('sia_ncnes_amb_mun_pcapita','N. of Health Facilities with Ambulatory Service (per capita*1000)'),
                 cbind('sia_ncnes_acs_pcapita','N. of Health Facilities with Ambulatory Service and ACS Teams (per capita*1000)'),
                 cbind('sia_ncnes_psf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Teams (per capita*1000)'),
                 cbind('sia_ncnes_medcom_pcapita','N. of Health Facilities with Ambulatory Service and Community Doctors (per capita*1000)'),
                 cbind('sia_ncnes_medpsf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Doctors (per capita*1000)'),
                 cbind('sia_ncnes_enfacs_pcapita','N. of Health Facilities with Ambulatory Service and ACS Nurses (per capita*1000)'),
                 cbind('sia_ncnes_enfpsf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Nurses (per capita*1000)'),
                 cbind('sia_ncnes_outpsf_pcapita','N. of Health Facilities with Ambulatory Service and PSF Nursing Assistants (per capita*1000)'),
                 
                 cbind('sia_pcapita','N. Outpatient Procedures (per capita)'),
                 cbind('sia_ab_pcapita','N. Primary Care Outpatient Procedures (per capita)'),
                 cbind('sia_nab_pcapita','N. Non-Primary Care Outpatient Procedures (per capita)'), # precisa criar
                 cbind('sia_nprod_amb_lc_mun_pcapita','N. Low & Mid Complexity Outpatient Procedures (per capita)'),
                 cbind('sia_nprod_amb_hc_mun_pcapita','N. High Complexity Outpatient Procedures (per capita)'),
                 
                 cbind('birth_prenat_ig','Proportion of births with unknown prenatal care coverage'),
                 cbind('birth_prenat_0','Proportion of births with 0 prenatal visits'),
                 cbind('birth_prenat_1_6','Proportion of births with 1-6 prenatal visits'),
                 cbind('birth_prenat_7_plus','Proportion of births with 7+ prenatal visits')
                 
                 
)

# continuous 1st vs 2nd

for (i in seq(1,2,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-1,1,0.2,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

for (i in seq(3,5,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-1,1.5,0.5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in seq(6,8,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-2,3.5,0.5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


# for (i in seq(9,16,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly(var,var_name,df,3,1998,-0.5,0.5,0.1,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2007, cont = 1) # ec29baseline
# }


for (i in seq(17,21,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-7,14,1,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in seq(22,25,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-0.5,0.5,0.1,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}






# continuous 1st term

for (i in seq(1,2,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),3,1998,-1,1,0.2,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

for (i in seq(3,5,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),3,1998,-1,1.5,0.5,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in seq(6,8,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),3,1998,-2,3.5,0.5,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


# for (i in seq(9,16,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly(var,var_name,df,3,1998,-0.5,0.5,0.1,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2007, cont = 1) # ec29baseline
# }


for (i in seq(17,21,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),3,1998,-7,14,1,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in seq(22,25,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),3,1998,-0.5,0.5,0.1,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}






# 4. Inputs
# =================================================================

yearly_folder <- "regs_plots_pbc/inputs/"


var_map <- rbind(cbind('ams_hospital_mun_pcapita','N. of Municipal Hospitals (per capita*1000)'),
                 cbind('ams_hospital_nmun_pcapita','N. of Federal and State Hospitals (per capita*1000)'),
                 cbind('ams_hospital_pvt_pcapita','N. of Private Hospitals (per capita*1000)'),
                 
                 cbind('ams_hr_all_pcapita',"N. of Health Professionals (per capita*1000)"),
                 cbind('ams_hr_superior_pcapita','N. of Doctors (per capita*1000)'),
                 cbind('ams_hr_technician_pcapita','N. of Nurses (per capita*1000)'),
                 cbind('ams_hr_elementary_pcapita','N. of Nursing Assistants (per capita*1000)'),
                 cbind('ams_hr_admin_pcapita','N. of Administrative Professionals (per capita*1000)')
                 
                 # cbind('ams_hospital_mun_esp_pcapita', 'N. of Specialty Hospitals (per capita*1000)'),
                 # cbind('ams_unity_mun_pcapita','N. of Health Facilities (per capita*1000)'),
                 # cbind('ams_therapy_mun_pcapita','N. of Therapy Units (per capita*1000)')
)


# continuous 1st vs 2nd

for (i in seq(1,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df %>% mutate(below_pre_99_dist_ec29_baseline=0,above_pre_99_dist_ec29_baseline=0),3,1998,-0.04,0.1,0.02,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in 4){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df %>% mutate(below_pre_99_dist_ec29_baseline=0,above_pre_99_dist_ec29_baseline=0),3,1998,-30,50,10,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

for (i in seq(5,8,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df %>% mutate(below_pre_99_dist_ec29_baseline=0,above_pre_99_dist_ec29_baseline=0),3,1998,-15,30,5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}




# continuous 1st term

for (i in seq(1,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0) %>% mutate(pre_99_dist_ec29_baseline=0),3,1998,-0.04,0.1,0.02,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in 4){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0) %>% mutate(pre_99_dist_ec29_baseline=0),3,1998,-30,50,10,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

for (i in seq(5,8,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0) %>% mutate(pre_99_dist_ec29_baseline=0),3,1998,-15,30,5,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}



# 5. Hospitalization
# =================================================================

# yearly_folder <- "regs_plots/hosp/"
# 
# var_map <- rbind(cbind('tx_sih_infant','Infant Hospitalization Rate (pop 0-1y * 1000)'),
#                  cbind('tx_sih_infant_icsap','Infant Hospitalization Rate - APC (pop 0-1y * 1000)'),
#                  cbind('tx_sih_infant_nicsap','Infant Hospitalization Rate - non-APC (pop 0-1y * 1000)'),
#                  cbind('tx_sih_maternal2','Maternal Hospitalization Rate (pop 0-1y * 1000)'),
#                  cbind('tx_sih_maternal','Maternal Hospitalization Rate (women 10-49y * 1000)')
#                  
#                  
# )
# 
# 
# # continuous
# for (i in seq(1,4,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly(var,var_name,df,3,1998,-600,1000,200,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
# }
# 
# for (i in seq(5,5,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly(var,var_name,df,3,1998,-50,50,10,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont =1) # ec29baseline
# }



# 6. Fertility and Birth
# =================================================================

yearly_folder <- "regs_plots_pbc/birth/"


var_map <- rbind(cbind('birth_fertility','Fertility (N. of Births per 10-49y women)'),
                 cbind('birth_apgar1','Apgar 1'),
                 cbind('birth_apgar5','Apgar 5'),
                 cbind('birth_low_weight_2500g','Low Birth Weight (<2.5k)'),
                 cbind('birth_premature','Premature Birth'),
                 cbind('birth_sexratio',"Sex Ratio at Birth"))


# continuous 1st vs 2nd

for (i in c(1,seq(4,6,1))){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-0.2,0.3,0.05,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

for (i in seq(2,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-1,1.5,0.5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}



# continuous 1st term

for (i in c(1,seq(4,6,1))){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),3,1998,-0.2,0.3,0.05,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

for (i in seq(2,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly(var,var_name,df %>% filter(second_term==0),3,1998,-1,1.5,0.5,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}



# 7. IMR
# =================================================================

yearly_folder <- "regs_plots_pbc/imr/"

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
                  cbind('tx_mi_ano','Infant Mortality Rate - 27 days to 1 year'),
                  cbind('tx_mm',"Maternal Mortality Rate"))

# continuous 1st and 2nd

for (i in seq(1,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab_imr(var,var_name,df,3,1998,-30,20,5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in seq(4,15,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab_imr(var,var_name,df,3,1998,-20,20,5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

# for (i in seq(16,16,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly_ab_imr(var,var_name,df,3,1998,-15,10,5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
# }



# continuous 1st term

for (i in seq(1,3,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_imr(var,var_name,df %>% filter(second_term==0),3,1998,-30,20,5,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in seq(4,15,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_imr(var,var_name,df %>% filter(second_term==0),3,1998,-20,20,5,paste0("2_first_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

# for (i in seq(16,16,1)){
#   var <- var_map[i,1]
#   var_name <- var_map[i,2]
#   print(var_name)
#   reduced_yearly_ab_imr(var,var_name,df,3,1998,-15,10,5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
# }





# 8. Indexes
# =================================================================

index <- data.frame(read.dta13("C:/Users/Michel/Documents/GitHub/ec29/indexes.dta"))


# merge indexes to main df
all_df <- c("df")

imerge <- function(df){
  df <- df %>% 
    left_join(index, by = c("ano","cod_mun","cod_uf"))
}

for(d in all_df){
  df_merge <- get(d)
  df_merge <- df_merge %>% imerge()
  assign(d,df_merge,envir = .GlobalEnv)
}

yearly_folder <- "regs_plots_pbc/indexes/"


var_map <-  rbind(cbind('access_index','Access and Production of Health Services Index','peso_pop'),
                  cbind('access_pc_index','Primary Care Access and Production Index','peso_pop'),
                  cbind('access_npc_index','Non-Primary Care Access and Production Index','peso_pop'),
                  cbind('input_index','Health Inputs Index','peso_pop'),
                  cbind('hr_index','Human Resources Index','peso_pop'),
                  cbind('hospital_index','Hospitals Index','peso_pop'),
                  cbind('birth_index','Birth Outcomes Index','peso_pop'),
                  cbind('imr_index','Infant Mortality Index','peso_pop'),
                  cbind('birth_others_index','Other Birth Outcomes Index','peso_pop')
)


# continous

for (i in c(seq(1,3,1),7,9)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df,3,1998,-1,1.75,0.25,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}

for (i in seq(4,6,1)){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab(var,var_name,df %>% mutate(below_pre_99_dist_ec29_baseline=0,above_pre_99_dist_ec29_baseline=0),3,1998,-1,3.5,0.5,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


for (i in 8){
  var <- var_map[i,1]
  var_name <- var_map[i,2]
  print(var_name)
  reduced_yearly_ab_imr(var,var_name,df,3,1998,-1,1.75,0.25,paste0("1_terms_level_",i),weight = "peso_pop",year_cap = 2010, cont = 1) # ec29baseline
}


