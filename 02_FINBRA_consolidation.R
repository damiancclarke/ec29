#######################################################################################################
# Author: Michel Szklo
# June 2020
# 
# This script consolidates data on from FINBRA on public spending in Brazil.
# 
# MS Access files where downloaded from the link below and then converted to excel tables
#
# http://www.tesouro.fazenda.gov.br/contas-anuais
# https://www.gov.br/tesouronacional/pt-br/estados-e-municipios/dados-consolidados/finbra-financas-municipais
#
#######################################################################################################

# =================================================================
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
            'textclean')
to_install<-packages[!(packages %in% installed.packages()[,"Package"])]
if(length(to_install)>0) install.packages(to_install)

lapply(packages,require,character.only=TRUE)


# SET PATH FOR EC 29-2000 ON YOUR COMPUTER
# ------------------------------------

dir <- "G:/My Drive/DOUTORADO FGV/Artigos/EC 29-2000/"

# ------------------------------------

# working directories
raw <- paste0(dir,"data/Finbra/finbra_excel/")
output <- paste0(dir,"data/Finbra/")



# data set with municipalities IDs
id_mun <- read.csv(file =paste0(raw,"municipios.csv"), encoding = "UTF-8")
colnames(id_mun)[6] <- "mun"
colnames(id_mun)[9] <- "uf"

id_mun <- id_mun %>% 
  mutate(mun_merge = replace_non_ascii(gsub("-","",gsub("'","",gsub(" ","",tolower(mun))))),
         uf = as.character(uf)) %>% 
  dplyr::select(c("id_munic_6","uf","mun_merge")) %>% 
  rename("cod_mun" = "id_munic_6")


# #################################################################
#       DESPESAS
# #################################################################




# =================================================================
# 1. FINBRA 1998 and 1999
# =================================================================

for (ano in c(1998,1999)) {
  
  temp <- read.csv(file = paste0(raw,"finbra",ano,"_despesa.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('X.U.FEFF.UF','MUNICIPIO','Populacao.2000','Despesas.Orçamentárias','Desp.Correntes','Desp.de.Pessoal','Despesas.de.Capital','Investimentos','Legislativa','Judiciária','Planejamento','Agricultura','Educação.e.Cultura','Habitação.e.Urbanismo','Indústria.e.Comércio','Saúde.e.Saneamento','Assistência.e.Previdência','Transporte','Segurança.Pública','Desenvolvimento.Regional','Energia.e.Recursos.Minerais','Comunicações'))
  colnames(temp) <- c('uf','nome_mun','pop2000','desp_o','desp_c','desp_pessoal','desp_capital','desp_investimento','desp_legislativa','desp_judiciaria','desp_adm','desp_agricultura','desp_educ_cultura','desp_hab_urb','desp_ind_com','desp_saude_san','desp_assist_prev','desp_transporte','desp_seguranca','desp_devregional','desp_energia','desp_comunicacoes')
  temp <- temp %>% mutate(nome_mun = as.character(nome_mun), uf = as.character(uf))
  
  names_map <- rbind(
    c('LIVRAMENTO DO BRUMADO', 'LIVRAMENTO DE NOSSA SENHORA','BA'),
    c('MUQUEM DO SAO FRANCISCO', 'MUQUEM DE SAO FRANCISCO','BA'),
    c('BRASOPOLIS', 'BRAZOPOLIS', 'MG'),
    c('DONA EUZEBIA', 'DONA EUSEBIA','MG'),
    c('GOUVEA' ,'GOUVEIA','MG'),
    c('QUELUZITA', 'QUELUZITO','MG'),
    c('SANTA RITA DO IBITIPOCA', 'SANTA RITA DE IBITIPOCA','MG'),
    c('SAO TOME DAS LETRAS', 'SAO THOME DAS LETRAS','MG'),
    c('BATAIPORA', 'BATAYPORA','MS'),
    c('SAO BENTO DE POMBAL', 'SAO BENTINHO','PB'),
    c('SAO DOMINGOS DE POMBAL', 'SAO DOMINGOS','PB'),
    c('CARNAUBEIRAS DA PENHA', 'CARNAUBEIRA DA PENHA','PE'),
    c('LAGOA DO ITAENGA', 'LAGOA DE ITAENGA','PE'),
    c('BELA VISTA DO CAROBA', 'BELA VISTA DA CAROBA','PR'),
    c('VILA ALTA', 'ALTO PARAISO','PR'),
    c('PARATI', 'PARATY','RJ'),
    c('TRAJANO DE MORAIS', 'TRAJANO DE MORAES','RJ'),
    c('SAO MIGUEL DE TOUROS', 'SAO MIGUEL DO GOSTOSO','RN'),
    c('SERRA CAIADA', 'PRESIDENTE JUSCELINO','RN'),
    c('JAMARI', 'CANDEIAS DO JAMARI','RO'),
    c('CHIAPETA', 'CHIAPETTA','RS'),
    c('PICARRAS', 'BALNEARIO PICARRAS','SC'),
    c("SAO MIGUEL D'OESTE", 'SAO MIGUEL DO OESTE','SC'),
    c('BRODOSQUI', 'BRODOWSKI','SP'),
    c('EMBU', 'EMBU DAS ARTES','SP'),
    c('IPAUCU', 'IPAUSSU','SP'),
    c('MOJI DAS CRUZES', 'MOGI DAS CRUZES','SP'),
    c('MOJI-GUACU', 'MOGI-GUACU','SP'),
    c('MOSQUITO', 'PALMEIRAS DO TOCANTINS','TO'),
    c('SANTAREM','JOCA CLAUDINO','PB'),
    c('PRESIDENTE CASTELO BRANCO','PRESIDENTE CASTELLO BRANCO','SC'),
    c('ITABIRINHA DE MANTENA', 'ITABIRINHA','MG')
  )
  
  for (i in seq(1,nrow(names_map),1)){
    
    old <- names_map[i,1]
    new <- names_map[i,2]
    s <- names_map[i,3]
    
    temp <- temp %>% mutate(nome_mun = ifelse(nome_mun==old,ifelse(uf==s,new,nome_mun),nome_mun))
  }
  
  
  temp <- temp %>% 
    mutate(mun_merge = replace_non_ascii(gsub("-","",gsub("'","",gsub(" ","",tolower(as.character(nome_mun)))))))
  
  temp <- left_join(temp,id_mun, by = c("mun_merge","uf"))
  temp$ano <- ano
  temp <- temp %>% select(-mun_merge)
  
  if (ano==1998){
    finbra <- temp
  } else{
    finbra <- bind_rows(finbra, temp)
  }
  
}


# =================================================================
# 2. FINBRA 2000 and 2001
# =================================================================

for (ano in c(2000,2001)){
  # temp <- read.xlsx(file = paste0(raw,"finbra",ano,"_despesa.xlsx"),sheetIndex = 1, encoding = "UTF-8")
  temp <- read.csv(file = paste0(raw,"finbra",ano,"_despesa.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('X.U.FEFF.CD_UF','CD_MUN','UF','MUNICIPIO','Populacao.2000','Despesas.Orçamentárias','Desp.Correntes','Desp.de.Pessoal','Despesas.de.Capital','Investimentos','Legislativa','Judiciária','Planejamento','Agricultura','Educação.e.Cultura','Habitação.e.Urbanismo','Indústria.e.Comércio','Saúde.e.Saneamento','Assistência.e.Previdência','Transporte','Segurança.Pública','Desenvolvimento.Regional','Energia.e.Recursos.Minerais','Comunicações'))
  colnames(temp) <- c('cod_uf','cod_mun','uf','nome_mun','pop2000','desp_o','desp_c','desp_pessoal','desp_capital','desp_investimento','desp_legislativa','desp_judiciaria','desp_adm','desp_agricultura','desp_educ_cultura','desp_hab_urb','desp_ind_com','desp_saude_san','desp_assist_prev','desp_transporte','desp_seguranca','desp_devregional','desp_energia','desp_comunicacoes')
  temp <- temp %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n)
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
}

# =================================================================
# 3. FINBRA 2002
# =================================================================
ano <- 2002
temp <- read.csv(file = paste0(raw,"finbra",ano,"_despesa.csv"), encoding = "UTF-8",sep = ";")
temp <- temp %>% select(c('X.U.FEFF.CD_UF','CD_MUN','UF','NOME.DO.MUNICIPIO.SIAFI','Populacao','Pessoal.e.Encarg.Soc_PES','Despesas.Orçamentárias','Desp.Correntes','Despesas.de.Capital','Investimentos','Legislativa','Judiciária','Agricultura','Transporte','Segurança.Pública','Comunicações','Essencial.à.Justiça','Administração','Defesa.Nacional','Relações.Exteriores','Assistência.Social','Previdência.Social','Saúde','Trabalho','Educação','Cultura','Direitos.da.Cidadania','Urbanismo','Habitação','Saneamento','Gestão.Ambiental','Ciência.e.Tecnologia','Organização.Agrária','Indústria','Comércio.E.Serviços','Energia','Desporto.e.Lazer','Encargos.Especiais'))
colnames(temp) <- c('cod_uf','cod_mun','uf','nome_mun','pop','desp_pessoal','desp_o','desp_c','desp_capital','desp_investimento','desp_legislativa','desp_judiciaria','desp_agricultura','desp_transporte','desp_seguranca','desp_comunicacoes','desp_justica','desp_adm','desp_defesa','desp_rext','desp_assist','desp_prev','desp_saude','desp_trabalho','desp_educ','desp_cultura','desp_cidadania','desp_urb','desp_hab','desp_san','dep_gambiental','desp_ct','dep_orgagraria','desp_ind','desp_com','desp_energia','desp_esporte','desp_encargos')
temp <- temp %>%
  mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
         n = nchar(cod_mun),
         cod_mun = as.character(cod_mun)) %>%
  mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
  mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
  select(-n) %>% 
  mutate(desp_educ_cultura = desp_educ + desp_cultura,
         desp_hab_urb = desp_hab + desp_urb,
         desp_ind_com = desp_ind + desp_com,
         desp_saude_san = desp_saude + desp_san,
         desp_assist_prev = desp_assist + desp_prev)


temp[,6:ncol(temp)] <- sapply(temp[,6:ncol(temp)], as.character)

temp$ano <- ano

finbra <- bind_rows(finbra,temp)



# =================================================================
# 4. FINBRA 2003
# =================================================================
ano <- 2003
temp <- read.csv(file = paste0(raw,"finbra",ano,"_despesa.csv"), encoding = "UTF-8",sep = ";")
temp <- temp %>% select(c('X.U.FEFF.CD_UF','CD_MUN','UF','MUNICIPIO','Populacao','Pessoal.e.Encarg.Soc_PES','Despesas.Orçamentárias','Desp.Correntes','Despesas.de.Capital','Investimentos','Legislativa','Judiciária','Agricultura','Transporte','Segurança.Pública','Comunicações','Essencial.à.Justiça','Administração','Defesa.Nacional','Relações.Exteriores','Assistência.Social','Previdência.Social','Saúde','Trabalho','Educação','Cultura','Direitos.da.Cidadania','Urbanismo','Habitação','Saneamento','Gestão.Ambiental','Ciência.e.Tecnologia','Organização.Agrária','Indústria','Comércio.E.Serviços','Energia','Desporto.e.Lazer','Encargos.Especiais'))
colnames(temp) <- c('cod_uf','cod_mun','uf','nome_mun','pop','desp_pessoal','desp_o','desp_c','desp_capital','desp_investimento','desp_legislativa','desp_judiciaria','desp_agricultura','desp_transporte','desp_seguranca','desp_comunicacoes','desp_justica','desp_adm','desp_defesa','desp_rext','desp_assist','desp_prev','desp_saude','desp_trabalho','desp_educ','desp_cultura','desp_cidadania','desp_urb','desp_hab','desp_san','dep_gambiental','desp_ct','dep_orgagraria','desp_ind','desp_com','desp_energia','desp_esporte','desp_encargos')
temp <- temp %>%
  mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
         n = nchar(cod_mun),
         cod_mun = as.character(cod_mun)) %>%
  mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
  mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
  select(-n) %>% 
  mutate(desp_educ_cultura = desp_educ + desp_cultura,
         desp_hab_urb = desp_hab + desp_urb,
         desp_ind_com = desp_ind + desp_com,
         desp_saude_san = desp_saude + desp_san,
         desp_assist_prev = desp_assist + desp_prev)


temp[,6:ncol(temp)] <- sapply(temp[,6:ncol(temp)], as.character)

temp$ano <- ano

finbra <- bind_rows(finbra,temp)



# =================================================================
# 4. FINBRA 2004 - 2012
# =================================================================


for (ano in seq(2004,2012,1)){
  
  temp1 <- read.csv(file = paste0(raw,"finbra",ano,"_despesa.csv"), encoding = "UTF-8",sep = ";")
  temp1 <- temp1 %>% select(c('X.U.FEFF.CD_UF','CD_MUN','UF','MUNICIPIO','Populacao','Pessoal.e.Encarg.Soc_PES','Despesas.Orçamentárias','Desp.Correntes','Despesas.de.Capital','Investimentos'))
  colnames(temp1) <- c('cod_uf','cod_mun','uf','nome_mun','pop','desp_pessoal','desp_o','desp_c','desp_capital','desp_investimento')
  
  temp1[,6:ncol(temp1)] <- sapply(temp1[,6:ncol(temp1)], function(x) gsub(",","",x))
  temp1[,6:ncol(temp1)] <- sapply(temp1[,6:ncol(temp1)], as.character)
  temp1[,6:ncol(temp1)] <- sapply(temp1[,6:ncol(temp1)], as.numeric)
  
  temp1 <- temp1 %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n)
  
  
  temp2 <- read.csv(file = paste0(raw,"finbra",ano,"_despesa_funcao.csv"), encoding = "UTF-8",sep = ";")
  temp2 <- temp2 %>% select(c('X.U.FEFF.CdUF','CdMun','Legislativa','Judiciária','Agricultura','Transporte','Segurança.Pública','Comunicações','Essencial.à.Justiça','Administração','Defesa.Nacional','Relações.Exteriores','Assistência.Social','Previdência.Social','Saúde','Trabalho','Educação','Cultura','Direitos.da.Cidadania','Urbanismo','Habitação','Saneamento','Gestão.Ambiental','Ciência.e.Tecnologia','Organização.Agrária','Indústria','Comércio.e.Serviços','Energia','Desporto.e.Lazer','Encargos.Especiais'))
  colnames(temp2) <- c('cod_uf','cod_mun','desp_legislativa','desp_judiciaria','desp_agricultura','desp_transporte','desp_seguranca',
                       'desp_comunicacoes','desp_justica','desp_adm','desp_defesa','desp_rext','desp_assist','desp_prev','desp_saude',
                       'desp_trabalho','desp_educ','desp_cultura','desp_cidadania','desp_urb','desp_hab','desp_san','desp_gambiental',
                       'desp_ct','desp_orgagraria','desp_ind','desp_com','desp_energia','desp_esporte','desp_encargos')
  
  temp2[,6:ncol(temp2)] <- sapply(temp2[,6:ncol(temp2)], function(x) gsub(",","",x))
  temp2[,6:ncol(temp2)] <- sapply(temp2[,6:ncol(temp2)], as.character)
  temp2[,6:ncol(temp2)] <- sapply(temp2[,6:ncol(temp2)], as.numeric)
  
  temp2 <- temp2 %>%
    mutate(n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n)
  
  temp <- full_join(temp1, temp2, by = c("cod_mun","cod_uf"))
  
  temp <- temp %>%
    mutate(desp_educ_cultura = desp_educ + desp_cultura,
           desp_hab_urb = desp_hab + desp_urb,
           desp_ind_com = desp_ind + desp_com,
           desp_saude_san = desp_saude + desp_san,
           desp_assist_prev = desp_assist + desp_prev)
  
  temp[,6:ncol(temp)] <- sapply(temp[,6:ncol(temp)], as.character)
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
  
}


# =================================================================
# 5. FINBRA 2013 - 2019
# =================================================================

desp <- c("3.0.00.00.00.00 - Despesas Correntes",
          "3.1.00.00.00.00 - Pessoal e Encargos Sociais",
          "4.0.00.00.00.00 - Despesas de Capital",
          "4.4.00.00.00.00 - Investimentos")

desp2 <- c("3.0.00.00.00 - Despesas Correntes",
          "3.1.00.00.00 - Pessoal e Encargos Sociais",
          "4.0.00.00.00 - Despesas de Capital",
          "4.4.00.00.00 - Investimentos")

desp_func <- c("01 - Legislativa",
               "02 - Judiciária",
               "20 - Agricultura",
               "26 - Transporte",
               "06 - Segurança Pública",
               "24 - Comunicações",
               "03 - Essencial à Justiça",
               "04 - Administração",
               "05 - Defesa Nacional",
               "07 - Relações Exteriores",
               "08 - Assistência Social",
               "09 - Previdência Social",
               "10 - Saúde",
               "11 - Trabalho",
               "12 - Educação",
               "13 - Cultura",
               "14 - Direitos da Cidadania",
               "15 - Urbanismo",
               "16 - Habitação",
               "17 - Saneamento",
               "18 - Gestão Ambiental",
               "19 - Ciência e Tecnologia",
               "21 - Organização Agrária",
               "22 - Indústria",
               "23 - Comércio e Serviços",
               "25 - Energia",
               "27 - Desporto e Lazer",
               "28 - Encargos Especiais")




for(ano in seq.int(2013,2017)){
  
  temp1 <- read.csv(file = paste0(raw,"finbra",ano,"_despesa.csv"), encoding = "Latin1",sep = ";", skip = 3) %>%
    filter(Coluna == "Despesas Liquidadas") %>% 
    select(Cod.IBGE,Conta,Valor) %>% 
    filter(Conta %in% desp) %>% 
    mutate(Conta = substr(Conta,19,nchar(Conta)))
  
  temp1[,3] <- sapply(temp1[,3], function(x) gsub(",",".",x))
  temp1[,3] <- sapply(temp1[,3], as.numeric)
  
  temp1 <- temp1 %>% 
    pivot_wider(id_cols = "Cod.IBGE",
                names_from = "Conta",
                values_from = "Valor") 
  
  colnames(temp1) <- c("cod_mun","desp_c","desp_pessoal","desp_capital","desp_investimentos")
  
  
  
  temp2 <- read.csv(file = paste0(raw,"finbra",ano,"_despesa_funcao.csv"), encoding = "Latin1",sep = ";", skip = 3) %>%
    filter(Coluna == "Despesas Liquidadas") %>% 
    select(Cod.IBGE,Conta,Valor) %>% 
    filter(Conta %in% desp_func) %>% 
    mutate(Conta = substr(Conta,6,nchar(Conta)))
  
  temp2[,3] <- sapply(temp2[,3], function(x) gsub(",",".",x))
  temp2[,3] <- sapply(temp2[,3], as.numeric)
  
  temp2 <- temp2 %>% 
    pivot_wider(id_cols = "Cod.IBGE",
                names_from = "Conta",
                values_from = "Valor") 
  
  colnames(temp2) <- c('cod_mun','desp_adm','desp_assist','desp_saude','desp_educ','desp_cultura','desp_urb','desp_san','desp_gambiental',
                       'desp_agricultura','desp_com','desp_transporte','desp_esporte','desp_legislativa','desp_seguranca','desp_encargos',
                       'desp_prev','desp_hab','desp_ind','desp_cidadania','desp_energia','desp_judiciaria','desp_defesa','desp_trabalho',
                       'desp_ct','desp_comunicacoes','desp_justica','desp_orgagraria','desp_rext')
  
  
  temp <- full_join(temp1, temp2, by = c("cod_mun")) %>% 
    mutate(ano = ano)
  
  temp <- temp %>%
    mutate(desp_educ_cultura = desp_educ + desp_cultura,
           desp_hab_urb = desp_hab + desp_urb,
           desp_ind_com = desp_ind + desp_com,
           desp_saude_san = desp_saude + desp_san,
           desp_assist_prev = desp_assist + desp_prev) %>% 
    mutate(cod_mun = as.numeric(substr(as.character(cod_mun),1,6))) %>% 
    select(cod_mun,ano,everything())
  
  
  
  
  temp[is.na(temp)] <- 0
  
  temp[,3:ncol(temp)] <- sapply(temp[,3:ncol(temp)], as.character)
  
  finbra <- bind_rows(finbra,temp)
  
  print(ano)
  
}


for(ano in seq.int(2018,2019)){
  
  temp1 <- read.csv(file = paste0(raw,"finbra",ano,"_despesa.csv"), encoding = "Latin1",sep = ";", skip = 3) %>%
    filter(Coluna == "Despesas Liquidadas") %>% 
    select(Cod.IBGE,Conta,Valor) %>% 
    filter(Conta %in% desp2) %>% 
    mutate(Conta = substr(Conta,19,nchar(Conta)))
  
  temp1[,3] <- sapply(temp1[,3], function(x) gsub(",",".",x))
  temp1[,3] <- sapply(temp1[,3], as.numeric)
  
  temp1 <- temp1 %>% 
    pivot_wider(id_cols = "Cod.IBGE",
                names_from = "Conta",
                values_from = "Valor") 
  
  colnames(temp1) <- c("cod_mun","desp_c","desp_pessoal","desp_capital","desp_investimentos")
  
  
  
  temp2 <- read.csv(file = paste0(raw,"finbra",ano,"_despesa_funcao.csv"), encoding = "Latin1",sep = ";", skip = 3) %>%
    filter(Coluna == "Despesas Liquidadas") %>% 
    select(Cod.IBGE,Conta,Valor) %>% 
    filter(Conta %in% desp_func) %>% 
    mutate(Conta = substr(Conta,6,nchar(Conta)))
  
  temp2[,3] <- sapply(temp2[,3], function(x) gsub(",",".",x))
  temp2[,3] <- sapply(temp2[,3], as.numeric)
  
  temp2 <- temp2 %>% 
    pivot_wider(id_cols = "Cod.IBGE",
                names_from = "Conta",
                values_from = "Valor") 
  
  colnames(temp2) <- c('cod_mun','desp_adm','desp_assist','desp_saude','desp_educ','desp_cultura','desp_urb','desp_san','desp_gambiental',
                       'desp_agricultura','desp_com','desp_transporte','desp_esporte','desp_legislativa','desp_seguranca','desp_encargos',
                       'desp_prev','desp_hab','desp_ind','desp_cidadania','desp_energia','desp_judiciaria','desp_defesa','desp_trabalho',
                       'desp_ct','desp_comunicacoes','desp_justica','desp_orgagraria','desp_rext')
  
  
  temp <- full_join(temp1, temp2, by = c("cod_mun")) %>% 
    mutate(ano = ano)
  
  temp <- temp %>%
    mutate(desp_educ_cultura = desp_educ + desp_cultura,
           desp_hab_urb = desp_hab + desp_urb,
           desp_ind_com = desp_ind + desp_com,
           desp_saude_san = desp_saude + desp_san,
           desp_assist_prev = desp_assist + desp_prev) %>% 
    mutate(cod_mun = as.numeric(substr(as.character(cod_mun),1,6))) %>% 
    select(cod_mun,ano,everything())
  
  
  
  
  temp[is.na(temp)] <- 0
  
  temp[,3:ncol(temp)] <- sapply(temp[,3:ncol(temp)], as.character)
  
  finbra <- bind_rows(finbra,temp)
  
  print(ano)
  
}



# =================================================================
# 5. SAVING
# =================================================================

saveRDS(finbra, paste0(output,"FINBRA.rds"))


# =================================================================
# 6. Exporting main variables
# =================================================================

finbra_select <- finbra %>%
  select(c("cod_mun","ano","uf","nome_mun","pop","pop2000","desp_o","desp_c","desp_pessoal","desp_capital","desp_investimento","desp_legislativa","desp_judiciaria","desp_agricultura","desp_educ_cultura","desp_hab_urb","desp_ind_com","desp_saude_san","desp_transporte","desp_seguranca","desp_energia","desp_comunicacoes", "desp_adm"))

finbra_select[,4:ncol(finbra_select)] <- sapply(finbra_select[,4:ncol(finbra_select)], function(x) gsub(",","",x))
finbra_select[,4:ncol(finbra_select)] <- sapply(finbra_select[,4:ncol(finbra_select)], as.numeric)
write.table(finbra, paste0(output,"FINBRA.csv"), fileEncoding = "latin1", sep = ",", row.names = F)




# #################################################################
#       RECEITAS
# #################################################################


# =================================================================
# 1. FINBRA 1998 and 1999
# =================================================================


for (ano in c(1998,1999)) {
  
  temp <- read.csv(file = paste0(raw,"receita/finbra",ano,"_receita.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('UF','MUNICIPIO','Rec.Correntes','Rec.Orçamentária','Rec.Tributária','Rec.Transf.Correntes','Impostos','IPTU','ISS'))
  colnames(temp) <- c('uf','nome_mun','reccorr','recorc','rectribut','rectransf','impostos_total','iptu','iss')
  temp <- temp %>% mutate(nome_mun = as.character(nome_mun), uf = as.character(uf))
  
  names_map <- rbind(
    c('LIVRAMENTO DO BRUMADO', 'LIVRAMENTO DE NOSSA SENHORA','BA'),
    c('MUQUEM DO SAO FRANCISCO', 'MUQUEM DE SAO FRANCISCO','BA'),
    c('BRASOPOLIS', 'BRAZOPOLIS', 'MG'),
    c('DONA EUZEBIA', 'DONA EUSEBIA','MG'),
    c('GOUVEA' ,'GOUVEIA','MG'),
    c('QUELUZITA', 'QUELUZITO','MG'),
    c('SANTA RITA DO IBITIPOCA', 'SANTA RITA DE IBITIPOCA','MG'),
    c('SAO TOME DAS LETRAS', 'SAO THOME DAS LETRAS','MG'),
    c('BATAIPORA', 'BATAYPORA','MS'),
    c('SAO BENTO DE POMBAL', 'SAO BENTINHO','PB'),
    c('SAO DOMINGOS DE POMBAL', 'SAO DOMINGOS','PB'),
    c('CARNAUBEIRAS DA PENHA', 'CARNAUBEIRA DA PENHA','PE'),
    c('LAGOA DO ITAENGA', 'LAGOA DE ITAENGA','PE'),
    c('BELA VISTA DO CAROBA', 'BELA VISTA DA CAROBA','PR'),
    c('VILA ALTA', 'ALTO PARAISO','PR'),
    c('PARATI', 'PARATY','RJ'),
    c('TRAJANO DE MORAIS', 'TRAJANO DE MORAES','RJ'),
    c('SAO MIGUEL DE TOUROS', 'SAO MIGUEL DO GOSTOSO','RN'),
    c('SERRA CAIADA', 'PRESIDENTE JUSCELINO','RN'),
    c('JAMARI', 'CANDEIAS DO JAMARI','RO'),
    c('CHIAPETA', 'CHIAPETTA','RS'),
    c('PICARRAS', 'BALNEARIO PICARRAS','SC'),
    c("SAO MIGUEL D'OESTE", 'SAO MIGUEL DO OESTE','SC'),
    c('BRODOSQUI', 'BRODOWSKI','SP'),
    c('EMBU', 'EMBU DAS ARTES','SP'),
    c('IPAUCU', 'IPAUSSU','SP'),
    c('MOJI DAS CRUZES', 'MOGI DAS CRUZES','SP'),
    c('MOJI-GUACU', 'MOGI-GUACU','SP'),
    c('MOSQUITO', 'PALMEIRAS DO TOCANTINS','TO'),
    c('SANTAREM','JOCA CLAUDINO','PB'),
    c('PRESIDENTE CASTELO BRANCO','PRESIDENTE CASTELLO BRANCO','SC'),
    c('ITABIRINHA DE MANTENA', 'ITABIRINHA','MG')
  )
  
  for (i in seq(1,nrow(names_map),1)){
    
    old <- names_map[i,1]
    new <- names_map[i,2]
    s <- names_map[i,3]
    
    temp <- temp %>% mutate(nome_mun = ifelse(nome_mun==old,ifelse(uf==s,new,nome_mun),nome_mun))
  }
  
  
  temp <- temp %>% 
    mutate(mun_merge = replace_non_ascii(gsub("-","",gsub("'","",gsub(" ","",tolower(as.character(nome_mun)))))),
           reccorr = gsub(",","",reccorr),
           recorc = gsub(",","",recorc),
           rectribut = gsub(",","",rectribut),
           rectransf = gsub(",","",rectransf),
           impostos_total = gsub(",","",impostos_total),
           iput = gsub(",","",iptu),
           iss = gsub(",","",iss))
  
  temp <- left_join(temp,id_mun, by = c("mun_merge","uf"))
  temp$ano <- ano
  temp <- temp %>% select(-mun_merge)
  
  if (ano==1998){
    finbra <- temp
  } else{
    finbra <- bind_rows(finbra, temp)
  }
  
}


# =================================================================
# 2. FINBRA 2000 and 2010 (except 2002)
# =================================================================

for (ano in c(2000,2001)){
  # temp <- read.xlsx(file = paste0(raw,"finbra",ano,"_despesa.xlsx"),sheetIndex = 1, encoding = "UTF-8")
  temp <- read.csv(file = paste0(raw,"receita/finbra",ano,"_receita.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('CD_UF','CD_MUN','UF','MUNICIPIO','Rec.Correntes','Rec.Orçamentária','Rec.Tributária','Rec.Transf.Correntes','Impostos','IPTU','ISS'))
  colnames(temp) <- c('cod_uf','cod_mun','uf','nome_mun','reccorr','recorc','rectribut','rectransf','impostos_total','iptu','iss')
  temp <- temp %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n) %>% 
    mutate(reccorr = gsub(",","",reccorr),
           recorc = gsub(",","",recorc),
           rectribut = gsub(",","",rectribut),
           rectransf = gsub(",","",rectransf),
           impostos_total = gsub(",","",impostos_total),
           iptu = gsub(",","",iptu),
           iss = gsub(",","",iss))
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
}


# =================================================================
# 2. FINBRA 2003 to 2012
# =================================================================

for (ano in c(seq.int(2003,2012))){
  # temp <- read.xlsx(file = paste0(raw,"finbra",ano,"_despesa.xlsx"),sheetIndex = 1, encoding = "UTF-8")
  temp <- read.csv(file = paste0(raw,"receita/finbra",ano,"_receita.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('CD_UF','CD_MUN','UF','MUNICIPIO','Rec.Correntes','Rec.Orçamentária','Rec.Tributária','Rec.Transf.Correntes','Impostos','IPTU','ISSQN'))
  colnames(temp) <- c('cod_uf','cod_mun','uf','nome_mun','reccorr','recorc','rectribut','rectransf','impostos_total','iptu','iss')
  temp <- temp %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n) %>% 
    mutate(reccorr = gsub(",","",reccorr),
           recorc = gsub(",","",recorc),
           rectribut = gsub(",","",rectribut),
           rectransf = gsub(",","",rectransf),
           impostos_total = gsub(",","",impostos_total),
           iptu = gsub(",","",iptu),
           iss = gsub(",","",iss))
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
}


# =================================================================
# 3. FINBRA 2002 
# =================================================================

for (ano in c(2002)){
  # temp <- read.xlsx(file = paste0(raw,"finbra",ano,"_despesa.xlsx"),sheetIndex = 1, encoding = "UTF-8")
  temp <- read.csv(file = paste0(raw,"receita/finbra",ano,"_receita.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('CD_UF','CD_MUN','UF','NOME.DO.MUNICIPIO.SIAFI','Rec.Correntes','Rec.Orçamentária','Rec.Tributária','Rec.Transf.Correntes','Impostos','IPTU','ISSQN'))
  colnames(temp) <- c('cod_uf','cod_mun','uf','nome_mun','reccorr','recorc','rectribut','rectransf','impostos_total','iptu','iss')
  temp <- temp %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n) %>% 
    mutate(reccorr = gsub(",","",reccorr),
           recorc = gsub(",","",recorc),
           rectribut = gsub(",","",rectribut),
           rectransf = gsub(",","",rectransf),
           impostos_total = gsub(",","",impostos_total),
           iptu = gsub(",","",iptu),
           iss = gsub(",","",iss))
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
}


# =================================================================
# 2. FINBRA 2013 and 2018 
# =================================================================

# 
# 
# for (ano in seq.int(2013,2017)){
#   temp <- read.csv(file = paste0(raw,"receita/finbra",ano,"_receita.csv"))
#   temp <- read.csv(file = paste0(raw,"receita/finbra",ano,"_receita.csv"), encoding = "Latin-1",sep = ";", skip = 3)
#   temp <- temp %>% 
#     filter((Conta=="1.0.0.0.00.00.00 - Receitas Correntes" & (Coluna=="Receitas Realizadas" | Coluna == "Receitas Brutas Realizadas")) |
#              (Conta=="1.1.0.0.00.00.00 - Receita Tributária" & (Coluna=="Receitas Realizadas" | Coluna == "Receitas Brutas Realizadas")) |
#              (Conta=="1.7.0.0.00.00.00 - Transferências Correntes" & (Coluna=="Receitas Realizadas" | Coluna == "Receitas Brutas Realizadas"))) %>% 
#     rename(cod_mun = Cod.IBGE) %>% 
#     select(c("cod_mun","Conta","Valor")) %>% 
#     mutate(Conta = ifelse(Conta=="1.0.0.0.00.00.00 - Receitas Correntes","reccorr",Conta),
#            Conta = ifelse(Conta=="1.1.0.0.00.00.00 - Receita Tributária","rectribut",Conta),
#            Conta = ifelse(Conta=="1.7.0.0.00.00.00 - Transferências Correntes","rectransf",Conta)) %>% 
#     mutate(Conta = gsub(",",".",Conta),
#            cod_mun = substr(cod_mun,1,6),
#            cod_mun = as.numeric(cod_mun)) %>% 
#     pivot_wider(names_from = "Conta",
#                 values_from = "Valor")
#   
#   temp$ano <- ano
#   finbra <- bind_rows(finbra,temp)
# }
# 
# temp <- read.csv(file = paste0(raw,"receita/finbra",2018,"_receita.csv"), encoding = "Latin-1",sep = ";", skip = 3)
# temp <- temp %>% 
#   filter((Conta=="1.0.0.0.00.0.0 - Receitas Correntes" & (Coluna=="Receitas Realizadas" | Coluna == "Receitas Brutas Realizadas")) |
#            (Conta=="1.1.0.0.00.0.0 - Impostos, Taxas e Contribuições de Melhoria" & (Coluna=="Receitas Realizadas" | Coluna == "Receitas Brutas Realizadas")) |
#            (Conta=="1.7.0.0.00.0.0 - Transferências Correntes" & (Coluna=="Receitas Realizadas" | Coluna == "Receitas Brutas Realizadas"))) %>%
#   rename(cod_mun = Cod.IBGE) %>% 
#   select(c("cod_mun","Conta","Valor")) %>% 
#   mutate(Conta = ifelse(Conta=="1.0.0.0.00.0.0 - Receitas Correntes","reccorr",Conta),
#          Conta = ifelse(Conta=="1.1.0.0.00.0.0 - Impostos, Taxas e Contribuições de Melhoria","rectribut",Conta),
#          Conta = ifelse(Conta=="1.7.0.0.00.0.0 - Transferências Correntes","rectransf",Conta)) %>% 
#   mutate(Conta = gsub(",",".",Conta),
#          cod_mun = substr(cod_mun,1,6),
#          cod_mun = as.numeric(cod_mun)) %>% 
#   pivot_wider(names_from = "Conta",
#               values_from = "Valor")
# 
# 
# temp$ano <- 2018
# finbra <- bind_rows(finbra,temp)


# =================================================================
# 5. Exporting
# =================================================================


finbra_select <- finbra %>% select(c("cod_mun","ano","reccorr","recorc","rectribut","rectransf","impostos_total","iptu","iss"))
write.table(finbra_select, paste0(output,"FINBRA_receita.csv"), fileEncoding = "latin1", sep = ",", row.names = F)








# #################################################################
#       Passivo
# #################################################################


# =================================================================
# 1. FINBRA 1998 and 1999
# =================================================================


for (ano in c(1998,1999)) {
  
  temp <- read.csv(file = paste0(raw,"passivo/finbra",ano,"_passivo.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('UF','MUNICIPIO','Passivo','Passivo.Financeiro'))
  colnames(temp) <- c('uf','nome_mun','passivo','passivo_fin')
  temp <- temp %>% mutate(nome_mun = as.character(nome_mun), uf = as.character(uf))
  
  names_map <- rbind(
    c('LIVRAMENTO DO BRUMADO', 'LIVRAMENTO DE NOSSA SENHORA','BA'),
    c('MUQUEM DO SAO FRANCISCO', 'MUQUEM DE SAO FRANCISCO','BA'),
    c('BRASOPOLIS', 'BRAZOPOLIS', 'MG'),
    c('DONA EUZEBIA', 'DONA EUSEBIA','MG'),
    c('GOUVEA' ,'GOUVEIA','MG'),
    c('QUELUZITA', 'QUELUZITO','MG'),
    c('SANTA RITA DO IBITIPOCA', 'SANTA RITA DE IBITIPOCA','MG'),
    c('SAO TOME DAS LETRAS', 'SAO THOME DAS LETRAS','MG'),
    c('BATAIPORA', 'BATAYPORA','MS'),
    c('SAO BENTO DE POMBAL', 'SAO BENTINHO','PB'),
    c('SAO DOMINGOS DE POMBAL', 'SAO DOMINGOS','PB'),
    c('CARNAUBEIRAS DA PENHA', 'CARNAUBEIRA DA PENHA','PE'),
    c('LAGOA DO ITAENGA', 'LAGOA DE ITAENGA','PE'),
    c('BELA VISTA DO CAROBA', 'BELA VISTA DA CAROBA','PR'),
    c('VILA ALTA', 'ALTO PARAISO','PR'),
    c('PARATI', 'PARATY','RJ'),
    c('TRAJANO DE MORAIS', 'TRAJANO DE MORAES','RJ'),
    c('SAO MIGUEL DE TOUROS', 'SAO MIGUEL DO GOSTOSO','RN'),
    c('SERRA CAIADA', 'PRESIDENTE JUSCELINO','RN'),
    c('JAMARI', 'CANDEIAS DO JAMARI','RO'),
    c('CHIAPETA', 'CHIAPETTA','RS'),
    c('PICARRAS', 'BALNEARIO PICARRAS','SC'),
    c("SAO MIGUEL D'OESTE", 'SAO MIGUEL DO OESTE','SC'),
    c('BRODOSQUI', 'BRODOWSKI','SP'),
    c('EMBU', 'EMBU DAS ARTES','SP'),
    c('IPAUCU', 'IPAUSSU','SP'),
    c('MOJI DAS CRUZES', 'MOGI DAS CRUZES','SP'),
    c('MOJI-GUACU', 'MOGI-GUACU','SP'),
    c('MOSQUITO', 'PALMEIRAS DO TOCANTINS','TO'),
    c('SANTAREM','JOCA CLAUDINO','PB'),
    c('PRESIDENTE CASTELO BRANCO','PRESIDENTE CASTELLO BRANCO','SC'),
    c('ITABIRINHA DE MANTENA', 'ITABIRINHA','MG')
  )
  
  for (i in seq(1,nrow(names_map),1)){
    
    old <- names_map[i,1]
    new <- names_map[i,2]
    s <- names_map[i,3]
    
    temp <- temp %>% mutate(nome_mun = ifelse(nome_mun==old,ifelse(uf==s,new,nome_mun),nome_mun))
  }
  
  
  temp <- temp %>% 
    mutate(mun_merge = replace_non_ascii(gsub("-","",gsub("'","",gsub(" ","",tolower(as.character(nome_mun)))))),
           passivo = gsub(",","",passivo),
           passivo_fin = gsub(",","",passivo_fin))
  
  temp <- left_join(temp,id_mun, by = c("mun_merge","uf"))
  temp$ano <- ano
  temp <- temp %>% select(-mun_merge)
  
  if (ano==1998){
    finbra <- temp
  } else{
    finbra <- bind_rows(finbra, temp)
  }
  
}


# =================================================================
# 2. FINBRA 2000 and 2001
# =================================================================

for (ano in c(2000,2001)){
  temp <- read.csv(file = paste0(raw,"passivo/finbra",ano,"_passivo.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('CD_UF','UF','CD_MUN','MUNICIPIO','Passivo','Passivo.Financeiro'))
  colnames(temp) <- c('cod_uf','uf','cod_mun','nome_mun','passivo','passivo_fin')
  temp <- temp %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n) %>% 
    mutate(passivo = gsub(",","",passivo),
           passivo_fin = gsub(",","",passivo_fin))
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
}


# =================================================================
# 2. FINBRA 2000 and 2010 (except 2002)
# =================================================================

for (ano in c(seq.int(2003,2012))){
  temp <- read.csv(file = paste0(raw,"passivo/finbra",ano,"_passivo.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('CdUF','UF','CdMun','MUNICIPIO','Passivo','Passivo.Financeiro'))
  colnames(temp) <- c('cod_uf','uf','cod_mun','nome_mun','passivo','passivo_fin')
  temp <- temp %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n) %>% 
    mutate(passivo = gsub(",","",passivo),
           passivo_fin = gsub(",","",passivo_fin))
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
}


# =================================================================
# 3. FINBRA 2002 
# =================================================================

for (ano in c(2002)){
  temp <- read.csv(file = paste0(raw,"passivo/finbra",ano,"_passivo.csv"), encoding = "UTF-8",sep = ";")
  temp <- temp %>% select(c('CD_UF','UF','CD_MUN','MUNICIPIO','Passivo','Passivo.Financeiro'))
  colnames(temp) <- c('cod_uf','uf','cod_mun','nome_mun','passivo','passivo_fin')
  temp <- temp %>%
    mutate(nome_mun = as.character(nome_mun), uf = as.character(uf),
           n = nchar(cod_mun),
           cod_mun = as.character(cod_mun)) %>%
    mutate(cod_mun = ifelse(n==1, paste0("000",cod_mun), ifelse(n==2, paste0("00",cod_mun), ifelse(n==3,paste0("0",cod_mun),cod_mun)))) %>% 
    mutate(cod_mun = as.numeric(paste0(cod_uf,cod_mun))) %>% 
    select(-n) %>% 
    mutate(passivo = gsub(",","",passivo),
           passivo_fin = gsub(",","",passivo_fin))
  
  temp$ano <- ano
  
  finbra <- bind_rows(finbra,temp)
  
}



# =================================================================
# 5. Exporting
# =================================================================

finbra_select <- finbra %>% select(c("cod_mun","ano","passivo","passivo_fin"))
write.table(finbra_select, paste0(output,"FINBRA_passivo.csv"), fileEncoding = "latin1", sep = ",", row.names = F)

