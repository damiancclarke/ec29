#--------------------------------------------------------------------------------
#--- Author: Michel Szklo
#--- January 2024
#--- Edits: Damian Clarke
#---        Most recent: 27/03/2025 (DC)
#--- 
#--- This scripts estimates elasticity rates and bootstrap CIs.  Updated version
#---  now does this based on an IV given comments from Referee 1.
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------
#--- (0) Set-up
#--------------------------------------------------------------------------------
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
if(Sys.getenv("USERNAME")=="dcc213") {
  dir <- "/home/dcc213/investigacion/2021/decentralization/github/ec29/"
} else if(Sys.getenv("USERNAME")=="damian") {
  dir <- "/home/damian/investigacion/2021/decentralization/github/ec29/"
} else {
  dir <- "C:/Users/Michel/Google Drive/DOUTORADO FGV/Artigos/EC 29-2000/"
}
# ------------------------------------

set.seed(121316)

#--------------------------------------------------------------------------------
#--- (1) Load and subset data
#--------------------------------------------------------------------------------
load(paste0(dir,"regs.RData"))

# removing variables that will not be used
#------------------------------------------
# select outcomes
outcomes <- c("siops_despsaude_pcapita","finbra_desp_o_pcapita","finbra_desp_saude_san_pcapita","tx_mi","tx_mi_icsap","tx_mi_nicsap",
              "tx_mi_infec","tx_mi_resp","tx_mi_perinat","tx_mi_cong","tx_mi_ext","tx_mi_nut",
              "tx_mi_out","tx_mi_illdef","tx_mi_fet","tx_mi_24h","tx_mi_27d","tx_mi_ano")
df <- df %>%
  select(ano, cod_mun,mun_name,cod_uf,uf_y_fe,all_of(outcomes),iv,iv_a,iv_b,iv_binary,all_of(controls),pop,
         all_of(yeartreat_dummies),all_of(yeartreat_dummies_ab),all_of(yeartreat_dummies_binary),
         peso_eq,peso_b,peso_a,peso_a1,peso_a2,peso_a3,peso_r,peso_m,peso_ha,peso_ha1,peso_ha2,peso_pop,
         finbra_desp_saude_san_pcapita_neighbor,lrf)

# "finbra_desp_saude_san_pcapita","siops_despsaude_pcapita","tx_mi"

#--------------------------------------------------------------------------------
#--- (2) Set-up estimation
#--------------------------------------------------------------------------------


df_reg <- df %>% 
  select(ano, cod_mun,mun_name,cod_uf,uf_y_fe,all_of(outcomes),iv,iv_a,iv_b,iv_binary,all_of(controls),pop,
         all_of(yeartreat_dummies_ab),all_of(yeartreat_dummies),
         peso_eq,peso_b,peso_a,peso_a1,peso_a2,peso_a3,peso_r,peso_m,peso_ha,peso_ha1,peso_ha2,peso_pop,
         finbra_desp_saude_san_pcapita_neighbor,lrf) %>% 
  filter(ano>=year_filter)

weight_vector <- df_reg["peso_pop"] %>% unlist() %>% as.numeric()


spec_reduced<- get(paste0("spec",spec,"_post_y_imr"))
regformula <- as.formula(paste(var,spec_reduced))
fit <- felm(tx_mi ~  t_analf18m_baseline + t_espvida_baseline + t_e_anosestudo_baseline + 
            t_t_analf18m_baseline + t_pmpob_baseline + t_rdpc_baseline + t_gini_baseline + 
            t_sewage_gen_network_baseline + t_garbage_coll_service_baseline + t_water_gen_network_baseline + 
            t_elect_access_baseline + t_urb_baseline + gdp_mun_pcapita + pbf_pcapita + t_tx_mi_baseline  
            | cod_mun + uf_y_fe | () | cod_mun, data = df_reg, weights = weight_vector,exactDOF = 

stop("Stopping script execution.")

# 2. Functions
# =================================================================

# function to run regression for each dataframe and variable
f1 <- function(df,var,year_filter,spec){
  
  df_reg <- df
  
  
  # filtering regression variables
  df_reg <- df_reg %>% 
    select(ano, cod_mun,mun_name,cod_uf,uf_y_fe,all_of(var),iv,iv_a,iv_b,iv_binary,all_of(controls),pop,
           all_of(yeartreat_dummies),all_of(yeartreat_dummies_binary),
           peso_eq,peso_b,peso_a,peso_a1,peso_a2,peso_a3,peso_r,peso_m,peso_ha,peso_ha1,peso_ha2,peso_pop,
           finbra_desp_saude_san_pcapita_neighbor,lrf) %>% 
    filter(ano>=year_filter)
  
  #DCAug28 df_reg <- df_reg[complete.cases(df_reg),]
  
  
  
  # spec <- 3
  spec_reduced<- get(paste0("spec",spec,"_post_y_imr"))
  weight_vector <- df_reg["peso_pop"] %>% unlist() %>% as.numeric()
  
  regformula <- as.formula(paste(var,spec_reduced))
  fit <- felm(regformula, data = df_reg, weights = weight_vector,exactDOF = T)
  
  table <- fit %>% 
    broom::tidy() %>%
    slice(3:15) %>%
    select(term,estimate) %>%
    mutate(estimate = ifelse(substr(term,1,7)=="post_00",0,estimate)) %>% 
    mutate(year = seq.int(year_filter,2010)) %>%
    filter(!is.na(estimate))
  
  
  if(length(grep("tx_mi",var))>0){
    suffix <- "tx_mi"
  }else{
    suffix <- var
  }
  cols <- names(table)[2:2]
  cols <- sapply(cols, function(x) paste0(x,"_",suffix), simplify = "array", USE.NAMES = F)
  names(table)[2:2] <- cols
  
  return(table)
  
  
}

f1_ab <- function(df,var,year_filter,spec){
  
  df_reg <- df
  
  
  # filtering regression variables
  df_reg <- df_reg %>% 
    select(ano, cod_mun,mun_name,cod_uf,uf_y_fe,all_of(var),iv,iv_a,iv_b,iv_binary,all_of(controls),pop,
           all_of(yeartreat_dummies_ab),
           peso_eq,peso_b,peso_a,peso_a1,peso_a2,peso_a3,peso_r,peso_m,peso_ha,peso_ha1,peso_ha2,peso_pop,
           finbra_desp_saude_san_pcapita_neighbor,lrf) %>% 
    filter(ano>=year_filter)
  
  #DCAug28 df_reg <- df_reg[complete.cases(df_reg),]
  
  
  
  # spec <- 3
  spec_reduced<- get(paste0("spec",spec,"_post_y_imr_ab"))
  weight_vector <- df_reg["peso_pop"] %>% unlist() %>% as.numeric()
  
  regformula <- as.formula(paste(var,spec_reduced))
  fit <- felm(regformula, data = df_reg, weights = weight_vector,exactDOF = T)
  
  tableA <- fit %>% 
    broom::tidy() %>%
    slice(3:15) %>%
    select(term,estimate) %>%
    mutate(estimate = ifelse(substr(term,7,13)=="post_00",0,estimate)) %>% 
    mutate(year = seq.int(year_filter,2010),
           target = "Above") %>%
    filter(!is.na(estimate))
  
  tableB <- fit %>% 
    broom::tidy() %>%
    slice(18:30) %>%
    select(term,estimate) %>%
    mutate(estimate = ifelse(substr(term,7,13)=="post_00",0,estimate)) %>% 
    mutate(year = seq.int(year_filter,2010),
           target = "Below") %>%
    filter(!is.na(estimate))
  
  table <- rbind(tableA,tableB)
  
  if(length(grep("tx_mi",var))>0){
    suffix <- "tx_mi"
  }else{
    suffix <- var
  }
  cols <- names(table)[2:2]
  cols <- sapply(cols, function(x) paste0(x,"_",suffix), simplify = "array", USE.NAMES = F)
  names(table)[2:2] <- cols
  
  return(table)
  
}

# function for dist * post regs
f1_t <- function(df,var,year_filter,spec){
  
  df_reg <- df
  
  
  # filtering regression variables
  df_reg <- df_reg %>% 
    select(ano, cod_mun,mun_name,cod_uf,uf_y_fe,all_of(var),iv,iv_a,iv_b,iv_binary,all_of(controls),pop,
           all_of(yeartreat_dummies),all_of(yeartreat_dummies_binary),
           peso_eq,peso_b,peso_a,peso_a1,peso_a2,peso_a3,peso_r,peso_m,peso_ha,peso_ha1,peso_ha2,peso_pop,
           finbra_desp_saude_san_pcapita_neighbor,lrf) %>% 
    filter(ano>=year_filter)
  
  #DCAug28 df_reg <- df_reg[complete.cases(df_reg),]
  
  
  
  # spec <- 3
  spec_reduced<- get(paste0("spec",spec,"_post_imr_cont_c"))
  weight_vector <- df_reg["peso_pop"] %>% unlist() %>% as.numeric()
  
  regformula <- as.formula(paste(var,spec_reduced))
  fit <- felm(regformula, data = df_reg, weights = weight_vector,exactDOF = T)
  
  table <- fit %>% 
    broom::tidy() %>%
    slice(1) %>%
    select(term,estimate)
  
  
  if(length(grep("tx_mi",var))>0){
    suffix <- "tx_mi"
  }else{
    suffix <- var
  }
  cols <- names(table)[2:2]
  cols <- sapply(cols, function(x) paste0(x,"_",suffix), simplify = "array", USE.NAMES = F)
  names(table)[2:2] <- cols
  
  return(table)
  
  
}

# function that creates samples (with, without outlier), run regressions and outputs table
f2 <- function(df,var,year_filter, outlier, ab,spec=3){
  
  # create sample without spending outliers
  
  if (outlier == 1){
    
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
    
    df2 <- df %>% 
      filter(!(cod_mun %in% outliers))
    
    if(ab == 1){
      
      table <- f1_ab(df2,var,1998, spec)
      
    } else {
      
      table <- f1(df2,var,1998, spec)
    }
    
    
  } else {
    
    if(ab == 1){
      
      table <- f1_ab(df,var,1998,spec)
      
    } else{
      
      table <- f1(df,var,1998,spec)
      
    }
    
  }
  

  table <- table %>% 
    select(term,year,everything()) %>% 
    mutate(var = var)
  
  return(table)
}

# function for dist * post regs
f2_t <- function(df,var,year_filter, outlier,spec=3){
  
  
  # create sample without spending outliers
  
  if (outlier == 1){
    
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
    
    df2 <- df %>% 
      filter(!(cod_mun %in% outliers))
    
    
    table <- f1_t(df2,var,1998, spec)
    
    
  } else {
    
    table <- f1_t(df,var,1998,spec)
    
  }
  
  
  table <- table %>% 
    select(term,everything()) %>% 
    mutate(var = var)
  
  return(table)
}


# boot strap function
f3 <- function(df,n) {      #define function
  new_df <- data.frame(matrix(nrow = 82605, ncol = 116))
  unique_ids <- unique(n)      #unique firms
  sample_ids <- sample(unique_ids, size=length(unique_ids), replace=T ) #choose from unique firms randomly with replacement
  new_df <- do.call(rbind, lapply(sample_ids, function(x)  df[df$cod_mun==x,] ))  #fetch all years for each randomly picked firm and rbind
  return(new_df)
}

# 3. Main regressions
# =================================================================

# infant mortality variables
var_vector <- rbind(cbind('tx_mi','Infant Mortality Rate'),
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






# tables
# ------------------------------------


table <- function(var,s){
  t <- f2_t(df,var,1998,0,s) %>% 
    mutate(spec = s)
  return(t)
} 

t_siops <- do.call(bind_rows, lapply(seq.int(1,4), function(i) table("siops_despsaude_pcapita",i)))
t_finbra <- do.call(bind_rows, lapply(seq.int(1,4), function(i) table("finbra_desp_saude_san_pcapita",i)))

t_imr <- do.call(bind_rows, lapply(var_vector[,1], function(v) {
  lapply(seq.int(1, 4), function(i) table(v, i))
}))







# plots
# ------------------------------------

elasticity_spending <- f2(df,"siops_despsaude_pcapita",1998,1,0,3)

elasticity_spending_ab <- f2(df,"siops_despsaude_pcapita",1998,1,1,3)




elasticity <- lapply(1:nrow(var_vector), function(i) {
  
  var <- var_vector[i,1]
  var_elasticity <- f2(df,var,1998,0,0,3)
  
  return(list(elasticity_main = var_elasticity))
})

elasticity_main <- do.call(bind_rows, lapply(elasticity, "[[", "elasticity_main")) %>% 
  left_join(elasticity_spending %>% rename(spending = var), by = c("term","year"))


elasticity_ab <- lapply(1:nrow(var_vector), function(i) {
  
  var <- var_vector[i,1]
  var_elasticity_ab <- f2(df,var,1998,0,1,3)
  
  return(list(elasticity_main_ab = var_elasticity_ab))
})

elasticity_main_ab <- do.call(bind_rows, lapply(elasticity_ab, "[[", "elasticity_main_ab")) %>% 
  left_join(elasticity_spending_ab %>% rename(spending = var), by = c("term","year","target"))


# 4. Bootstrap regressions
# =================================================================

boots <- 1000
boots <- 500
elasticity_boots <- data.frame(matrix(nrow = 13*boots, ncol = 5))
colnames(elasticity_boots) <- c("term","year",paste0("estimate_","tx_mi"),paste0("estimate_","siops_despsaude_pcapita"),"boot")

boot_results <- lapply(1:boots, function(i) {
  print(paste0("Boot # ", i))
  set.seed(28121989 + i)
  
  elasticity_i <- data.frame()
  elasticity_i_ab <- data.frame()
  
  
  elasticity_spending <- f2(df %>% f3(df$cod_mun), "siops_despsaude_pcapita", 1998,1,0)
  
  elasticity <- lapply(1:nrow(var_vector), function(i) {
    var <- var_vector[i, 1]
    print(var)
    
    var_elasticity <- f2(df %>% f3(df$cod_mun), var, 1998,0,0,3)
    
    return(list(elasticity_i = var_elasticity))
  })
  
  elasticity_i <- do.call(bind_rows, lapply(elasticity, "[[", "elasticity_i")) %>% 
    left_join(elasticity_spending %>% rename(spending = var), by = c("term","year"))

  elasticity_i <- elasticity_i %>% mutate(boot = i)
  
  print("main regs")
  
  
  
  elasticity_spending_ab <- f2(df %>% f3(df$cod_mun), "siops_despsaude_pcapita", 1998,1,1)
  
  elasticity_ab <- lapply(1:nrow(var_vector), function(i) {
    var <- var_vector[i, 1]
    print(var)
    
    var_elasticity_ab <- f2(df %>% f3(df$cod_mun), var, 1998,0,1,3)
    
    return(list(elasticity_i_ab = var_elasticity_ab))
  })
  
  print("above and below regs")

  elasticity_i_ab <- do.call(bind_rows, lapply(elasticity_ab, "[[", "elasticity_i_ab")) %>% 
    left_join(elasticity_spending_ab %>% rename(spending = var), by = c("term","year","target"))
    
  elasticity_i_ab <- elasticity_i_ab %>% mutate(boot = i)
  
  # r1 <- (i - 1) * 13 + 1
  # r2 <- r1 + 12
  return(list(elasticity_i = elasticity_i, elasticity_i_ab = elasticity_i_ab))
  
})

# Combine results into a single data frame
elasticity_boots <- do.call(bind_rows, lapply(boot_results, "[[", "elasticity_i"))
elasticity_boots_ab <- do.call(bind_rows, lapply(boot_results, "[[", "elasticity_i_ab"))


# save
# saveRDS(elasticity_boots, paste0(dir,"regs_outputs/elasticity/bootstrap_estimates.rds"))
# saveRDS(elasticity_boots_ab, paste0(dir,"regs_outputs/elasticity/bootstrap_estimates_ab.rds"))

saveRDS(elasticity_boots, paste0(dir,"bootstrap_estimates.rds"))
saveRDS(elasticity_boots_ab, paste0(dir,"bootstrap_estimates_ab.rds"))





# 5. Calculating elasticities, elasticities CIs, and plots
# =================================================================

# removing outliers for spending data
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

df2 <- df %>% 
  filter(!(cod_mun %in% outliers))

# spending baseline mean
baseline_mean_spending <- df2 %>% 
  filter(ano==2000) %>% 
  summarise_at("siops_despsaude_pcapita", mean, na.rm = T) %>% 
  pull()


baseline_mean_spending2 <- df2 %>% 
  filter(ano==2000) %>% 
  summarise_at("finbra_desp_saude_san_pcapita", mean, na.rm = T) %>% 
  pull()


baseline_mean_imr <- lapply(1:nrow(var_vector), function (i){
  
  v <- var_vector[i,1]
  bm <- df %>% 
    filter(ano==2000) %>% 
    summarise_at(v, mean, na.rm = T) %>% 
    rename(mean_imr = 1) %>% 
    mutate(var = v)
  
})
baseline_mean_imr <- do.call(bind_rows, baseline_mean_imr)


# estimating elasticity table
#------------------------------------------------------------


t_imr_siops <- t_imr %>% 
  left_join(t_siops %>% select(estimate_siops_despsaude_pcapita,spec), by = "spec") %>% 
  left_join(baseline_mean_imr, by = "var") %>% 
  mutate(mean_spending = baseline_mean_spending) %>% 
  mutate(e = (estimate_tx_mi/mean_imr)/(estimate_siops_despsaude_pcapita/mean_spending)) %>% 
  select(var,spec,e) %>% 
  pivot_wider(names_from = "spec",
              id_cols = "var",
              values_from = "e")
  
names(t_imr_siops)[2:5] <- lapply(names(t_imr_siops)[2:5], function(x) paste0(x,"_siops"))


t_imr_finbra <- t_imr %>% 
  left_join(t_finbra %>% select(estimate_finbra_desp_saude_san_pcapita,spec), by = "spec") %>% 
  left_join(baseline_mean_imr, by = "var") %>% 
  mutate(mean_spending = baseline_mean_spending2) %>% 
  mutate(e = (estimate_tx_mi/mean_imr)/(estimate_finbra_desp_saude_san_pcapita/mean_spending)) %>% 
  select(var,spec,e) %>% 
  pivot_wider(names_from = "spec",
              id_cols = "var",
              values_from = "e")

names(t_imr_finbra)[2:5] <- lapply(names(t_imr_finbra)[2:5], function(x) paste0(x,"_finbra"))


elasticity_table <- t_imr_siops %>% 
  left_join(t_imr_finbra, by = "var")


write.table(elasticity_table, file = paste0(dir,main_folder,"elasticity_table.xls"),row.names = F)



# function to create elasticity plots for each IMR
#------------------------------------------------------------

ecalc_plot <- function(i) {
  
  v <- var_vector[i,1]
  
  
  # IMR baseline mean
  baseline_mean_tx_mi <- df %>% 
    filter(ano==2000) %>% 
    summarise_at(v, mean, na.rm = T) %>% 
    pull()
  
  
  # Calculating Elasticities
  elasticity_calc <- elasticity_main %>% 
    filter(var == v) %>% 
    mutate(mean_spending = baseline_mean_spending,
           mean_tx_mi = baseline_mean_tx_mi) %>% 
    mutate(e = (estimate_tx_mi/mean_tx_mi)/(estimate_siops_despsaude_pcapita/mean_spending))
  
  
  elasticity_calc_ab <- elasticity_main_ab %>% 
    filter(var == v) %>% 
    mutate(mean_spending = baseline_mean_spending,
           mean_tx_mi = baseline_mean_tx_mi) %>% 
    mutate(e = (estimate_tx_mi/mean_tx_mi)/(estimate_siops_despsaude_pcapita/mean_spending))
  
  
  # Calculating Confidence Intervals
  elasticity_ci <- elasticity_boots %>% 
    mutate(mean_spending = baseline_mean_spending,
           mean_tx_mi = baseline_mean_tx_mi) %>% 
    mutate(e = (estimate_tx_mi/mean_tx_mi)/(estimate_siops_despsaude_pcapita/mean_spending)) %>% 
    group_by(year) %>% 
    summarize(e_mean = mean(e, na.rm = TRUE),
              e_sd = sd(e, na.rm = TRUE),
              e_p025 = quantile(e, probs = 0.025, na.rm = T),
              e_p975 = quantile(e, probs = 0.975, na.rm = T))
  
  elasticity_ci_ab <- elasticity_boots_ab %>% 
    mutate(mean_spending = baseline_mean_spending,
           mean_tx_mi = baseline_mean_tx_mi) %>% 
    mutate(e = (estimate_tx_mi/mean_tx_mi)/(estimate_siops_despsaude_pcapita/mean_spending)) %>% 
    group_by(year,target) %>% 
    summarize(e_mean = mean(e, na.rm = TRUE),
              e_sd = sd(e, na.rm = TRUE),
              e_p025 = quantile(e, probs = 0.025, na.rm = T),
              e_p975 = quantile(e, probs = 0.975, na.rm = T))
  
  
  # merging ci into the main dataframe
  elasticity_calc <- elasticity_calc %>% 
    left_join(elasticity_ci, by = "year")
  elasticity_calc$e_p025 <- elasticity_calc$e-1.96*elasticity_calc$e_sd
  elasticity_calc$e_p975 <- elasticity_calc$e+1.96*elasticity_calc$e_sd

  elasticity_calc_ab <- elasticity_calc_ab %>% 
    left_join(elasticity_ci_ab, by = c("year","target"))
  elasticity_calc_ab$e_p025 <- elasticity_calc_ab$e-1.96*elasticity_calc_ab$e_sd
  elasticity_calc_ab$e_p975 <- elasticity_calc_ab$e+1.96*elasticity_calc_ab$e_sd
    
  
  # Plots
  # ----------------------------------------------------------------
  
  # main regs
  var_name <- var_vector[i,2]
  y_axis_title <- paste0("Elasticity: ",var_name)
  
  
  graph <- elasticity_calc %>% 
    ggplot(aes(x = year, y = e))+
    geom_hline(yintercept = 0, color = "red", size = 0.3, alpha = 1, linetype = "dashed") +
    geom_vline(xintercept = 2000, color = "#9e9d9d", size = 0.5, alpha = 1, linetype = "solid") +
    geom_point(size = 1.2, alpha = 1,color = "grey20",shape=0,stroke = 0.8) +
    geom_ribbon(aes(ymin = e_p025, ymax = e_p975),color = NA, alpha = 0.2) +
    scale_x_continuous(breaks = seq(2000,2010,1), limits = c(1999.5,2010+0.5)) +
    scale_y_continuous(breaks = seq(-0.7,0.3,0.1), limits = c(-0.701,0.3), labels = comma) +
    theme_light() +
    labs(y = y_axis_title,
         x = "Year") +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(size = 11, face = "bold"),
          axis.title.x = element_text(size=11),
          axis.title.y = element_text(size=11),
          axis.text = element_text(size = 11),
          legend.position="bottom")
  
  
  # ggsave(paste0(dir,"regs_outputs/elasticity/",v,"_elasticity.png"),
  #        plot = graph,
  #        device = "png",
  #        width = 7, height = 5,
  #        units = "in")
  # ggsave(paste0(dir,"regs_outputs/elasticity/",v,"_elasticity.pdf"),
  #        plot = graph,
  #        device = "pdf",
  #        width = 7, height = 5,
  #        units = "in")
  
  ggsave(paste0(dir,v,"_elasticity.pdf"),
         plot = graph,
         device = "pdf",
         width = 7, height = 5,
         units = "in")
  
  
  # Above and Below
  colors <-  c("#ef8a62","#67a9cf")
  
  graph <- elasticity_calc_ab %>% 
    ggplot(aes(x = year, y = e, color = target, group = target))+
    geom_hline(yintercept = 0, color = "red", size = 0.3, alpha = 1, linetype = "dashed") +
    geom_vline(xintercept = 2000, color = "#9e9d9d", size = 0.5, alpha = 1, linetype = "solid") +
    geom_point(size = 1, alpha = 1,shape=0,stroke = 0.8, position = position_dodge(width=0.1)) +
    geom_ribbon(aes(ymin = e_p025, ymax = e_p975, fill = target),color = NA, alpha = 0.2) +
    scale_x_continuous(breaks = seq(2000,2010,1), limits = c(1999.5,2010+0.5)) +
    scale_y_continuous(breaks = seq(-1.4,0.8,0.2), limits = c(-1.4,0.8), labels = comma) +
    scale_color_manual(values = colors) +
    theme_light() +
    labs(y = y_axis_title,
         x = "Year") +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(size = 10, face = "bold"),
          axis.title.x = element_text(size=10),
          axis.title.y = element_text(size=8),
          axis.text = element_text(size = 10),
          legend.position="bottom",
          legend.title = element_blank())
  
  # ggsave(paste0(dir,"regs_outputs/elasticity/",v,"_elasticity_ab.png"),
  #        plot = graph,
  #        device = "png",
  #        width = 7, height = 5,
  #        units = "in")
  # ggsave(paste0(dir,"regs_outputs/elasticity/",v,"_elasticity_ab.pdf"),
  #        plot = graph,
  #        device = "pdf",
  #        width = 7, height = 5,
  #        units = "in")
  
  ggsave(paste0(dir,v,"_elasticity_ab.png"),
         plot = graph,
         device = "png",
         width = 7, height = 5,
         units = "in")
  ggsave(paste0(dir,v,"_elasticity_ab.pdf"),
         plot = graph,
         device = "pdf",
         width = 7, height = 5,
         units = "in")
  
  
  
}
lapply(1:nrow(var_vector), ecalc_plot)


