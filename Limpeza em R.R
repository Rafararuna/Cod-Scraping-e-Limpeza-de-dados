library(tidyverse)
library(xlsx)

user = "Rafael"

rm_accent <- function(str,pattern="all") {
  # Rotinas e fun??es ?teis V 1.0
  # rm.accent - REMOVE ACENTOS DE PALAVRAS
  # Fun??o que tira todos os acentos e pontua??es de um vetor de strings.
  # Par?metros:
  # str - vetor de strings que ter?o seus acentos retirados.
  # patterns - vetor de strings com um ou mais elementos indicando quais acentos dever?o ser retirados.
  #            Para indicar quais acentos dever?o ser retirados, um vetor com os s?mbolos dever?o ser passados.
  #            Exemplo: pattern = c("?", "^") retirar? os acentos agudos e circunflexos apenas.
  #            Outras palavras aceitas: "all" (retira todos os acentos, que s?o "?", "`", "^", "~", "?", "?")
  if(!is.character(str))
    str <- as.character(str)
  
  pattern <- unique(pattern)
  
  if(any(pattern=="?"))
    pattern[pattern=="?"] <- "?"
  
  symbols <- c(
    acute = "????????????",
    grave = "??????????",
    circunflex = "??????????",
    tilde = "??????",
    umlaut = "???????????",
    cedil = "??"
  )
  
  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )
  
  accentTypes <- c("?","`","^","~","?","?")
  
  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern)) # opcao retirar todos
    return(chartr(paste(symbols, collapse=""), paste(nudeSymbols, collapse=""), str))
  
  for(i in which(accentTypes%in%pattern))
    str <- chartr(symbols[i],nudeSymbols[i], str)
  
  return(str)
}
if(user == "Pupe"){
  dados = read.csv2("C:/Users/Admin/Ermida/?caro Costa - Quadra Urbana/04 - Desenvolvimento/01 - Bases/banco_corrente051121.csv")}
if(user == "Rafael"){
  dados = read.csv2("C:/Users/Ermida/OneDrive - Ermida/Quadra Urbana/04 - Desenvolvimento/01 - Bases/banco_corrente051121.csv")}

#tab_suja=dados_sujo

limp_bg_vvr<-function(tab_suja){
  
  names(tab_suja)<-c("DATA_ID","TITULO","ENDERECO_COMP","BAIRRO","AREA","QUARTO","BANHEIRO","SUITE","VAGA","CONDOMINIO","IPTU","ANUNCIANTE","VALOR","DESCRICAO","DESCRICAO_COMP","FOTOS","SCRAPING_TIME","PAGE_URL")
  SADF<-tab_suja
  
  ###########################################################################################################################################################
  SADF$TITULO<-str_to_upper(rm_accent(SADF$TITULO))
  SADF<- SADF %>% drop_na(c("TITULO"))
  #tp_anuncio<- dbGetQuery(con,"SELECT * FROM TIPO_ANUNCIO;")
  #tp_anuncio<- tp_anuncio$TIPO_ANUNCIO
  SADF$TIPO_ANUNCIO<-str_extract(SADF$TITULO,"(VENDA|ALUGAR)")
  SADF$TIPO_ANUNCIO<-ifelse(SADF$TIPO_ANUNCIO=="ALUGAR","ALUGUEL",SADF$TIPO_ANUNCIO)
  SADF$TIPO_ANUNCIO<-ifelse(is.na(SADF$TIPO_ANUNCIO),"LANCAMENTO",SADF$TIPO_ANUNCIO)
  ###########################################################################################################################################################
  #dbSendQuery(con,"INSERT INTO TIPOS_IMOVEIS_VIVAREAL VALUES('PREDIO RESIDENCIAL')")
  #SADF<- SADF %>% drop_na(c("TITULO"))
  #tp<- dbGetQuery(con,"SELECT * from TIPOS_IMOVEIS_VIVAREAL;")
  # tp<- tp$TIPOS_IMOVEIS_VIVAREAL
  SADF$TIPO_IMOVEL<-str_extract(SADF$TITULO,"(LOTE\\/TERRENO|CASA|APARTAMENTO|PREDIO COMERCIAL|FAZENDA\\/SITIO|LOTE RESIDENCIAL|CASA CONDOMINIO|LOTE COMERCIAL|PONTO COMERCIAL|GALPAO\\/DEPOSITO\\/ARMAZEM|CHACARA|FLAT|HOTEL|SALA CLINICA|KITNET|COBERTURA|CASA SOBRADO|PREDIO RESIDENCIAL|GARAGEM|LOJA|SALA COMERCIAL|SOBRADO|IMOVEL COMERCIAL|CONSULTORIO|KITNET KITNET-STUDIO|APARTAMENTO DUPLEX|SALA|KITNET MOBILIADO|CASA DE CONDOMINIO|APARTAMENTO COBERTURA|HOTEL FLAT|LOJA SOBRELOJA|GALPAO|APARTAMENTO LOFT|PREDIO MISTO|PONTO COMERCIAL GALPAO|SALA CONSULTORIO|APARTAMENTO MOBILIADO|CASA CONDOMINIO SOBRADO|SALA ANDAR|PONTO COMERCIAL PREDIO|PONTO COMERCIAL HOTEL|LOTE INDUSTRIAL|PONTO COMERCIAL PADARIA|PONTO COMERCIAL POSTO DE GASOLINA|CASA BARRACAO|PONTO COMERCIAL POUSADA|APARTAMENTO TRIPLEX|PONTO COMERCIAL FARMACIA)")
  
  
  ###########################################################################################################################################################
  SADF<- SADF %>% drop_na(c("ENDERECO_COMP"))
  SADF$ENDERECO_COMP<-str_to_upper(rm_accent(SADF$ENDERECO_COMP))
  
  ###########################################################################################################################################################
  #est<-dbGetQuery(con,"SELECT * from ESTADOS_BR;")
  #est<-est$ESTADO
  SADF$ESTADO<-str_extract(SADF$ENDERECO_COMP,"(\\- BA|\\- PB|\\- AL|\\- MS|\\- MT|\\- MG|\\- PE|\\- RO|\\- RR|\\- SE|\\- AC|\\- AP|\\- AM|\\- DF|\\- ES|\\- SP|\\- MA|\\- PA|\\- PR|\\- PI|\\- RN|\\- TO|\\- CE|\\- RJ|\\- RS|\\- SC|\\- GO)")
  SADF$ESTADO<-str_replace(SADF$ESTADO,"\\- ","")
  ###########################################################################################################################################################
  #mun<-dbGetQuery(con,"SELECT * from MUNICIPIOS_BR;")
  #mun<-mun$Mun
  #
  #library(xlsx)
  #library(tidyverse)
  #mun = read.xlsx2("C:/Users/Admin/Ermida/?caro Costa - Quadra Urbana/04 - Desenvolvimento/ibge - qu.xlsx",sheetIndex = 1)
  #mun=mun$NOME.DO.MUNIC?PIO.
  #mun=str_trim(str_to_upper(rm_accent(mun)))
  #mun<- paste0(", ",mun," -")
  #SADF$ENDERECO_COMP<-str_trim(str_to_upper(rm_accent(SADF$ENDERECO_COMP)))
  #SADF$CIDADE<- extrair(mun,SADF$ENDERECO_COMP)
  #SADF$CIDADE<- str_replace(SADF$CIDADE,", ","")
  #SADF$CIDADE<- str_replace(SADF$CIDADE," -","")
  
  cidade<-str_extract(SADF$ENDERECO_COMP,".*\\-")
  cidade<-paste0("-",cidade)
  cidade<-str_split(cidade,",")
  cidade2<-c()
  for(i in 1:length(cidade)){
    for(j in 1:length(cidade[[i]])){
      k=length(cidade[[i]])
      b<-as.vector(cidade[[i]])
      cidade2[i]<- b[k]
    }}
  cidade<-str_trim(str_replace_all(cidade2,"-",""))
  
  SADF$CIDADE<- cidade
  
  
  
  
  ##########################################################################################################################################################
  SADF$BAIRRO<-str_to_upper(rm_accent(SADF$BAIRRO))
  
  bairro<- str_extract(SADF$ENDERECO_COMP,".*\\,")
  bairro<- paste0(" - ",bairro)
  bairro<- str_split(bairro,"-")
  bairro2<-c()
  for(i in 1:length(bairro)){
    for(j in 1:length(bairro[[i]])){
      k=length(bairro[[i]])
      b<-as.vector(bairro[[i]])
      bairro2[i]<- b[k]
    }}
  
  bairro<-str_trim(str_replace_all(bairro2,",",""))
  SADF$BAIRRO<- bairro
  ###########################################################################################################################################################
  #SADF<- SADF %>% drop_na(c("AREA"))
  area<- str_replace_all(SADF$AREA,"m?","")
  area<- str_split(area," a ",simplify = T)[,1]
  SADF$AREA<-as.numeric(area)
  #SADF<- SADF %>% filter(AREA>1)
  ###########################################################################################################################################################
  SADF$QUARTO<-str_replace_all(SADF$QUARTO," quarto","")
  SADF$QUARTO<-str_replace_all(SADF$QUARTO,"s","")
  SADF$QUARTO<-as.numeric(SADF$QUARTO)
  SADF$QUARTO<- ifelse(is.na(SADF$QUARTO),0,SADF$QUARTO)
  ###########################################################################################################################################################
  SADF$BANHEIRO<-str_split(SADF$BANHEIRO,"\r",simplify = T)[,1]
  SADF$BANHEIRO<-str_replace_all(SADF$BANHEIRO," banheiro","")
  SADF$BANHEIRO<-str_replace_all(SADF$BANHEIRO,"s","")
  SADF$BANHEIRO<-as.numeric(SADF$BANHEIRO)
  SADF$BANHEIRO<- ifelse(is.na(SADF$BANHEIRO),0,SADF$BANHEIRO)
  ###########################################################################################################################################################
  SADF$SUITE<-str_replace_all(SADF$SUITE," su?te","")
  SADF$SUITE<-str_replace_all(SADF$SUITE,"s","")
  SADF$SUITE<-as.numeric(SADF$SUITE)
  SADF$SUITE<- ifelse(is.na(SADF$SUITE),0,SADF$SUITE)
  ###########################################################################################################################################################
  SADF$VAGA<-str_replace_all(SADF$VAGA," vaga","")
  SADF$VAGA<-str_replace_all(SADF$VAGA,"s","")
  SADF$VAGA<-as.numeric(SADF$VAGA)
  SADF$VAGA<- ifelse(is.na(SADF$VAGA),0,SADF$VAGA)
  ###########################################################################################################################################################
  SADF$CONDOMINIO<-str_replace_all(SADF$CONDOMINIO,"\\$","")
  SADF$CONDOMINIO<-str_replace_all(SADF$CONDOMINIO,"R","")
  SADF$CONDOMINIO<-str_trim(str_replace_all(SADF$CONDOMINIO,"\\.",""))
  SADF$CONDOMINIO<-as.numeric(SADF$CONDOMINIO)
  SADF$CONDOMINIO<- ifelse(is.na(SADF$CONDOMINIO),0,SADF$CONDOMINIO)
  ###########################################################################################################################################################
  SADF$IPTU<-str_replace_all(SADF$IPTU,"\\$","")
  SADF$IPTU<-str_replace_all(SADF$IPTU,"R","")
  SADF$IPTU<-str_trim(str_replace_all(SADF$IPTU,"\\.",""))
  SADF$IPTU<-as.numeric(SADF$IPTU)
  SADF$IPTU<- ifelse(is.na(SADF$IPTU),0,SADF$IPTU)
  ###########################################################################################################################################################
  SADF$ANUNCIANTE<-str_to_upper(rm_accent(SADF$ANUNCIANTE))
  ###########################################################################################################################################################
  SADF<- SADF %>% drop_na(c("VALOR"))
  SADF$VALOR<-str_split(SADF$VALOR,"\\/",simplify = T)[,1]
  SADF$VALOR<-str_replace_all(SADF$VALOR,"\\$","")
  SADF$VALOR<-str_replace_all(SADF$VALOR,"R","")
  SADF$VALOR<-str_trim(str_replace_all(SADF$VALOR,"\\.",""))
  SADF$VALOR<-as.numeric(SADF$VALOR)
  SADF$VALOR<- ifelse(is.na(SADF$VALOR),0,SADF$VALOR)
  SADF<- SADF %>% filter(VALOR>1)
  ###########################################################################################################################################################
  SADF$VALOR_M2<-(SADF$VALOR/SADF$AREA)
  ###########################################################################################################################################################
  SADF$DESCRICAO<-str_to_upper(rm_accent(SADF$DESCRICAO))
  ###########################################################################################################################################################
  SADF$DESCRICAO_COMP<-str_to_upper(rm_accent(SADF$DESCRICAO_COMP))
  ###########################################################################################################################################################
  SADF$PAGE_URL<-str_to_upper(rm_accent(SADF$PAGE_URL))
  ###########################################################################################################################################################
  #SADF$COD_ANUNCIO<-str_to_upper(rm_accent(SADF$COD_ANUNCIO))
  ###########################################################################################################################################################
  SADF$VALOR_LN<- log(SADF$VALOR)
  ###########################################################################################################################################################
  SADF$VALOR_M2_LN<-log(SADF$VALOR_M2)
  ###########################################################################################################################################################
  
  NOREP<- SADF %>% distinct(AREA,QUARTO,BANHEIRO,VALOR,.keep_all = T)
  
  
  TABELA_LIMPA<- select(NOREP,c("DATA_ID","TITULO","TIPO_ANUNCIO","TIPO_IMOVEL",
                                "ENDERECO_COMP","ESTADO","CIDADE","BAIRRO","AREA",
                                "QUARTO","BANHEIRO","SUITE","VAGA","CONDOMINIO",
                                "IPTU","VALOR","VALOR_LN","VALOR_M2","VALOR_M2_LN",
                                "ANUNCIANTE","DESCRICAO",#"DESCRICAO_COMP",
                                "FOTOS","SCRAPING_TIME","PAGE_URL"))
  
  names(TABELA_LIMPA)[c(5,ncol(TABELA_LIMPA))]<-c("RUA_OU_QUADRA","LINK")
  
  TABELA_LIMPA <- TABELA_LIMPA %>% drop_na(c("RUA_OU_QUADRA","AREA","VALOR"))
  
  
  #tryCatch({
  #  dbWriteTable(con, "TABELA_GERAL42" , TABELA_LIMPA, append=T)
  #  print(paste0("A tabela inserida foi limpa e adicionada (com ",nrow(TABELA_LIMPA)," dados) à TABELA_GERAL_LIMPA no banco-teste"))
  #         },error=function(cond){
  #                     print("Erro ao inserir dados no SQL")
  #                     print(cond)})
  
  TABELA_LIMPA$SITE<- "VIVAREAL" 
  return(TABELA_LIMPA)
  
}

limpeza_dfi_completa<-function(tab_suja){
  tab_suja_dfi_novo <- tab_suja
  
  #DATA_ID
  names(tab_suja_dfi_novo)[1] <- "DATA_ID"
  
  #LINK:
  names(tab_suja_dfi_novo)[13] <- "LINK"
  
  #TIPO_IMOVEL e TIPO_ANUNCIO:
  tab_suja_dfi_novo$DETALHES1<-str_to_upper(rm_accent(tab_suja_dfi_novo$DETALHES1))
  tab_suja_dfi_novo$DETALHES1<-str_replace(tab_suja_dfi_novo$DETALHES1," PADRAO","")
  TIPO <- str_split(tab_suja_dfi_novo$DETALHES1," DE ", simplify = T,n=2)
  tab_suja_dfi_novo$TIPO_ANUNCIO<-TIPO[,1]
  tab_suja_dfi_novo$TIPO_IMOVEL<-TIPO[,2]
  
  #RUA_OU_QUADRA:
  tab_suja_dfi_novo$ENDERECO_COMP<-rm_accent(tab_suja_dfi_novo$ENDERECO_COMP)
  TIPO <- str_split(tab_suja_dfi_novo$ENDERECO_COMP,"//\n", simplify = T,n=2)
  tab_suja_dfi_novo$RUA_OU_QUADRA<-TIPO[,1]
  
  #BAIRRO E CIDADE:
  tab_suja_dfi_novo$GERAL<-rm_accent(tab_suja_dfi_novo$GERAL)
  CIDADE_BAIRRO <- str_extract(tab_suja_dfi_novo$GERAL,"\nCidade:.*\n")
  CIDADE_BAIRRO <- str_replace(CIDADE_BAIRRO, "\nCidade: ", "")
  CIDADE_BAIRRO <- str_replace(CIDADE_BAIRRO, "\n", "")
  CIDADE_BAIRRO <- str_split(CIDADE_BAIRRO, " - ", simplify = T, n=2)
  tab_suja_dfi_novo$CIDADE <- CIDADE_BAIRRO[,1]
  tab_suja_dfi_novo$BAIRRO <- CIDADE_BAIRRO[,2]
  
  #AREA:
  tab_suja_dfi_novo$AREA<- str_replace_all(tab_suja_dfi_novo$AREA,'?rea ?til: ','')
  AREA <- str_split(tab_suja_dfi_novo$AREA, " ", simplify = T, n=2)
  AREA <- data.frame(AREA)
  AREA[,1]<- str_replace_all(AREA[,1],'\\.','')
  AREA[,1]<- str_replace_all(AREA[,1],',','\\.')
  AREA[,1] <- as.numeric(AREA[,1])
  AREA[,1] <- if_else(AREA[,2]=="ha", AREA[,1]*10000,AREA[,1])
  tab_suja_dfi_novo$AREA <- AREA[,1]
  tab_suja_dfi_novo<- tab_suja_dfi_novo %>% drop_na(c("AREA"))
  tab_suja_dfi_novo<- tab_suja_dfi_novo %>% filter(AREA>1)
  
  #QUARTO:
  tab_suja_dfi_novo$GERAL<- str_to_upper(rm_accent(tab_suja_dfi_novo$GERAL))
  QUARTO <- str_extract(tab_suja_dfi_novo$GERAL,"\n.*QUARTO")
  QUARTO <- str_replace(QUARTO, " QUARTO", "")
  QUARTO <- str_replace(QUARTO, "\n", "")
  #QUARTO <- str_extract_all(QUARTO, "[0-9]")
  QUARTO <- str_split(QUARTO, " ")
  
  QUARTO2 <- c()
  for(i in 1:length(QUARTO)){
    for(j in 1:length(QUARTO[[i]])){
      k=length(QUARTO[[i]])
      b<-as.vector(QUARTO[[i]])
      QUARTO2[i]<- b[k]
    }}
  
  QUARTO2 <- ifelse(is.na(QUARTO2), 1000000, QUARTO2)
  QUARTO2 <- as.numeric(QUARTO2)
  QUARTO2 <- ifelse(is.na(QUARTO2), 1, QUARTO2)
  QUARTO2 <- ifelse(QUARTO2==1000000, NA, QUARTO2)
  
  
  QUARTO2 <- str_trim(QUARTO2)
  sum(is.na(as.numeric(QUARTO2)))
  tab_suja_dfi_novo$QUARTO <- as.numeric(QUARTO2)
  
  
  #BANHEIRO:
  tab_suja_dfi_novo$BANHEIRO <- NA
  
  #SUITE:
  tab_suja_dfi_novo$GERAL<- str_to_upper(rm_accent(tab_suja_dfi_novo$GERAL))
  SUITE <- str_extract(tab_suja_dfi_novo$GERAL,"\n.*SUITE")
  SUITE <- str_replace(SUITE, " SUITE", "")
  SUITE <- str_replace_all(SUITE, "\n", "")
  #SUITE <- str_extract_all(SUITE, "[0-9]")
  SUITE <- str_split(SUITE, " ")
  
  SUITE2 <- c()
  for(i in 1:length(SUITE)){
    for(j in 1:length(SUITE[[i]])){
      k=length(SUITE[[i]])
      b<-as.vector(SUITE[[i]])
      SUITE2[i]<- b[k]
    }}
  
  SUITE2 <- ifelse(is.na(SUITE2), 1000000,SUITE2)
  SUITE2 <- as.numeric(SUITE2)
  SUITE2 <- ifelse(is.na(SUITE2), 1, SUITE2)
  SUITE2 <- ifelse(SUITE2==1000000, NA, SUITE2)
  
  
  SUITE2 <- str_trim(SUITE2)
  sum(is.na(SUITE2))
  tab_suja_dfi_novo$SUITE <- as.numeric(SUITE2)
  
  
  #VAGA:
  tab_suja_dfi_novo$GERAL<- str_to_upper(rm_accent(tab_suja_dfi_novo$GERAL))
  VAGA <- str_extract(tab_suja_dfi_novo$GERAL,"\n.*VAGA")
  VAGA <- str_replace(VAGA, " VAGA", "")
  VAGA <- str_replace(VAGA, "\n", "")
  #VAGA <- str_extract_all(VAGA, "[0-9]")
  VAGA <- str_split(VAGA, " ")
  
  VAGA2 <- c()
  for(i in 1:length(VAGA)){
    for(j in 1:length(VAGA[[i]])){
      k=length(VAGA[[i]])
      b<-as.vector(VAGA[[i]])
      VAGA2[i]<- b[k]
    }}
  
  VAGA2 <- ifelse(is.na(VAGA2), 1000000,VAGA2)
  VAGA2 <- as.numeric(VAGA2)
  VAGA2 <- ifelse(is.na(VAGA2), 1, VAGA2)
  VAGA2 <- ifelse(VAGA2==1000000, NA,VAGA2)
  
  
  VAGA2 <- str_trim(VAGA2)
  sum(is.na(VAGA2))
  tab_suja_dfi_novo$VAGA <- as.numeric(VAGA2)
  
  #VALOR:
  VALOR<- str_replace_all(tab_suja_dfi_novo$VALOR,'\\.','')
  VALOR<- str_replace_all(VALOR,'SIMULAR CR?DITO','')
  VALOR<- str_replace_all(VALOR,',','\\.')
  VALOR<- str_replace_all(VALOR,'\\$','')
  VALOR<- str_replace_all(VALOR,'R','')
  VALOR<-str_trim(VALOR)
  tab_suja_dfi_novo$VALOR<-as.numeric(VALOR)
  
  tab_suja_dfi_novo<- tab_suja_dfi_novo %>% drop_na(c("VALOR"))
  tab_suja_dfi_novo<- tab_suja_dfi_novo %>% filter(VALOR>1)
  
  #VALOR_M2:
  tab_suja_dfi_novo$VALOR_M2 <- tab_suja_dfi_novo$VALOR/tab_suja_dfi_novo$AREA
  
  #VALOR_LN:
  tab_suja_dfi_novo$VALOR_LN <- log(tab_suja_dfi_novo$VALOR)
  
  #VALOR_M2_LN:
  tab_suja_dfi_novo$VALOR_M2_LN <- log(tab_suja_dfi_novo$VALOR_M2)
  
  #DESCRICAO:
  tab_suja_dfi_novo$DESCRICAO <- tab_suja_dfi_novo$DESCRICAO_COMP
  
  #SCRAPING_TIME:
  dia= str_split(Sys.Date(),"-",simplify = T)[1,3] 
  mes= str_split(Sys.Date(),"-",simplify = T)[1,2] 
  ano= str_split(Sys.Date(),"-",simplify = T)[1,1] 
  tab_suja_dfi_novo$SCRAPING_TIME <- paste0(dia,"/",mes,"/",ano)
  #SITE:
  tab_suja_dfi_novo$SITE <- "DFIMOVEIS"
  
  #FOTO:
  
  tab_suja_dfi_novo$FOTOS <- tab_suja_dfi_novo$FOTO1
  
  
  tab_suja_dfi_novo2 <- tab_suja_dfi_novo %>% distinct(AREA,VALOR,LINK, .keep_all = TRUE)
  
  return(tab_suja_dfi_novo2)}

limp_bg_vvr_2<-function(tab_suja,tipo_imovel){
  
  names(tab_suja)<-c("DATA_ID","TITULO","ENDERECO_COMP","AREA","QUARTO","BANHEIRO","SUITE","VAGA","CONDOMINIO","IPTU","ANUNCIANTE","VALOR_VENDA","VALOR_ALUGUEL","DESCRICAO","DESCRICAO_COMP","FOTOS","SCRAPING_TIME","LINK")
  SADF<-tab_suja
  SADF$DATA_ID=seq(1:nrow(SADF))
  ###########################################################################################################################################################
  SADF$TITULO<-str_to_upper(rm_accent(SADF$TITULO))
  SADF<- SADF %>% drop_na(c("TITULO"))
  #tp_anuncio<- dbGetQuery(con,"SELECT * FROM TIPO_ANUNCIO;")
  #tp_anuncio<- tp_anuncio$TIPO_ANUNCIO
  
  SADF = SADF %>% distinct(LINK,.keep_all = T)
  SADF=pivot_longer(SADF,c("VALOR_VENDA","VALOR_ALUGUEL"),names_to = "TIPO_ANUNCIO",values_to = "VALOR",values_drop_na = TRUE)
  #SADF$TIPO_ANUNCIO= str_split(SADF$TIPO_ANUNCIO,"_",simplify = T)[,2]
  
  SADF$TIPO_ANUNCIO= ifelse(str_detect(SADF$VALOR,"/"),"ALUGUEL","VENDA")
  
  
  
  ###########################################################################################################################################################
  #dbSendQuery(con,"INSERT INTO TIPOS_IMOVEIS_VIVAREAL VALUES('PREDIO RESIDENCIAL')")
  #SADF<- SADF %>% drop_na(c("TITULO"))
  #tp<- dbGetQuery(con,"SELECT * from TIPOS_IMOVEIS_VIVAREAL;")
  # tp<- tp$TIPOS_IMOVEIS_VIVAREAL
  SADF$TIPO_IMOVEL<-str_extract(SADF$TITULO,"(LOTE\\/TERRENO|PREDIO COMERCIAL|FAZENDA\\/SITIO|LOTE RESIDENCIAL|CASA CONDOMINIO|LOTE COMERCIAL|PONTO COMERCIAL|GALPAO\\/DEPOSITO\\/ARMAZEM|CHACARA|FLAT|HOTEL|SALA CLINICA|KITNET|COBERTURA|CASA SOBRADO|PREDIO RESIDENCIAL|GARAGEM|LOJA|SALA COMERCIAL|SOBRADO|IMOVEL COMERCIAL|CONSULTORIO|KITNET KITNET-STUDIO|APARTAMENTO DUPLEX|SALA|KITNET MOBILIADO|CASA DE CONDOMINIO|CASAS DE CONDOMINIO|APARTAMENTO COBERTURA|HOTEL FLAT|LOJA SOBRELOJA|GALPAO|APARTAMENTO LOFT|PREDIO MISTO|PONTO COMERCIAL GALPAO|SALA CONSULTORIO|APARTAMENTO MOBILIADO|CASA CONDOMINIO SOBRADO|SALA ANDAR|PONTO COMERCIAL PREDIO|PONTO COMERCIAL HOTEL|LOTE INDUSTRIAL|PONTO COMERCIAL PADARIA|PONTO COMERCIAL POSTO DE GASOLINA|CASA BARRACAO|PONTO COMERCIAL POUSADA|APARTAMENTO TRIPLEX|PONTO COMERCIAL FARMACIA|CASA|APARTAMENTO)")
  
  SADF$LANCAMENTO <- ifelse(is.na(SADF$TIPO_IMOVEL),"SIM","NAO")
  
  SADF$TIPO_IMOVEL<- ifelse(is.na(SADF$TIPO_IMOVEL),tipo_imovel,SADF$TIPO_IMOVEL)
  ###########################################################################################################################################################
  SADF<- SADF %>% drop_na(c("ENDERECO_COMP"))
  SADF$ENDERECO_COMP<-str_to_upper(rm_accent(SADF$ENDERECO_COMP))
  
  ###########################################################################################################################################################
  #est<-dbGetQuery(con,"SELECT * from ESTADOS_BR;")
  #est<-est$ESTADO
  #SADF$ESTADO<-str_extract(SADF$ENDERECO_COMP,"(\\- BA|\\- PB|\\- AL|\\- MS|\\- MT|\\- MG|\\- PE|\\- RO|\\- RR|\\- SE|\\- AC|\\- AP|\\- AM|\\- DF|\\- ES|\\- SP|\\- MA|\\- PA|\\- PR|\\- PI|\\- RN|\\- TO|\\- CE|\\- RJ|\\- RS|\\- SC|\\- GO)")
  #SADF$ESTADO<-str_replace(SADF$ESTADO,"\\- ","")
  SADF$ENDERECO_COMP = str_replace_all(SADF$ENDERECO_COMP," VER NO MAPA","")
  estado<- vector()
  for(i in 1:length(SADF$ENDERECO_COMP)){
    estado[i]=str_sub(SADF$ENDERECO_COMP[i], start = (str_length(SADF$ENDERECO_COMP[i])-1) ,end = str_length(SADF$ENDERECO_COMP[i]))
  }
  SADF$ESTADO=estado
  
  ###########################################################################################################################################################
  #mun<-dbGetQuery(con,"SELECT * from MUNICIPIOS_BR;")
  #mun<-mun$Mun
  #
  #library(xlsx)
  #library(tidyverse)
  #mun = read.xlsx2("C:/Users/Admin/Ermida/?caro Costa - Quadra Urbana/04 - Desenvolvimento/ibge - qu.xlsx",sheetIndex = 1)
  #mun=mun$NOME.DO.MUNIC?PIO.
  #mun=str_trim(str_to_upper(rm_accent(mun)))
  #mun<- paste0(", ",mun," -")
  #SADF$ENDERECO_COMP<-str_trim(str_to_upper(rm_accent(SADF$ENDERECO_COMP)))
  #SADF$CIDADE<- extrair(mun,SADF$ENDERECO_COMP)
  #SADF$CIDADE<- str_replace(SADF$CIDADE,", ","")
  #SADF$CIDADE<- str_replace(SADF$CIDADE," -","")
  
  cidade<-str_extract(SADF$ENDERECO_COMP,".*\\-")
  cidade<-paste0("-",cidade)
  cidade<-str_split(cidade,",")
  cidade2<-c()
  for(i in 1:length(cidade)){
    for(j in 1:length(cidade[[i]])){
      k=length(cidade[[i]])
      b<-as.vector(cidade[[i]])
      cidade2[i]<- b[k]
    }}
  cidade<-str_trim(str_replace_all(cidade2,"-",""))
  
  SADF$CIDADE<- cidade
  
  
  
  
  ##########################################################################################################################################################
  
  
  bairro<- str_extract(SADF$ENDERECO_COMP,".*\\,")
  bairro<- paste0(" - ",bairro)
  bairro<- str_split(bairro,"-")
  bairro2<-c()
  for(i in 1:length(bairro)){
    for(j in 1:length(bairro[[i]])){
      k=length(bairro[[i]])
      b<-as.vector(bairro[[i]])
      bairro2[i]<- b[k]
    }}
  
  bairro<-str_trim(str_replace_all(bairro2,",",""))
  SADF$BAIRRO<- bairro
  ###########################################################################################################################################################
  #SADF<- SADF %>% drop_na(c("AREA"))
  area<- str_replace_all(SADF$AREA,"m?","")
  area<- str_split(area," a ",simplify = T)[,1]
  SADF$AREA<-as.numeric(area)
  #SADF<- SADF %>% filter(AREA>1)
  ###########################################################################################################################################################
  SADF$QUARTO<-str_split(SADF$QUARTO," ",simplify = T)[,1]
  SADF$QUARTO<-as.numeric(SADF$QUARTO)
  SADF$QUARTO<- ifelse(is.na(SADF$QUARTO),0,SADF$QUARTO)
  ###########################################################################################################################################################
  SADF$BANHEIRO<-str_split(SADF$BANHEIRO," ",simplify = T)[,1]
  SADF$BANHEIRO<-as.numeric(SADF$BANHEIRO)
  SADF$BANHEIRO<- ifelse(is.na(SADF$BANHEIRO),0,SADF$BANHEIRO)
  ###########################################################################################################################################################
  SADF$SUITE<-str_split(SADF$SUITE," ",simplify = T)[,1]
  SADF$SUITE<-as.numeric(SADF$SUITE)
  SADF$SUITE<- ifelse(is.na(SADF$SUITE),0,SADF$SUITE)
  ###########################################################################################################################################################
  SADF$VAGA<-str_split(SADF$VAGA," ",simplify = T)[,1]
  SADF$VAGA<-as.numeric(SADF$VAGA)
  SADF$VAGA<- ifelse(is.na(SADF$VAGA),0,SADF$VAGA)
  ###########################################################################################################################################################
  SADF$CONDOMINIO<-str_replace_all(SADF$CONDOMINIO,"\\$","")
  SADF$CONDOMINIO<-str_replace_all(SADF$CONDOMINIO,"R","")
  SADF$CONDOMINIO<-str_trim(str_replace_all(SADF$CONDOMINIO,"\\.",""))
  SADF$CONDOMINIO<-as.numeric(SADF$CONDOMINIO)
  SADF$CONDOMINIO<- ifelse(is.na(SADF$CONDOMINIO),0,SADF$CONDOMINIO)
  ###########################################################################################################################################################
  SADF$IPTU<-str_replace_all(SADF$IPTU,"\\$","")
  SADF$IPTU<-str_replace_all(SADF$IPTU,"R","")
  SADF$IPTU<-str_trim(str_replace_all(SADF$IPTU,"\\.",""))
  SADF$IPTU<-as.numeric(SADF$IPTU)
  SADF$IPTU<- ifelse(is.na(SADF$IPTU),0,SADF$IPTU)
  ###########################################################################################################################################################
  SADF$ANUNCIANTE<-str_to_upper(rm_accent(SADF$ANUNCIANTE))
  ###########################################################################################################################################################
  SADF<- SADF %>% drop_na(c("VALOR"))
  SADF$VALOR<-str_split(SADF$VALOR,"\\/",simplify = T)[,1]
  SADF$VALOR<-str_replace_all(SADF$VALOR,"\\$","")
  SADF$VALOR<-str_replace_all(SADF$VALOR,"R","")
  SADF$VALOR<-str_trim(str_replace_all(SADF$VALOR,"\\.",""))
  SADF$VALOR<-as.numeric(SADF$VALOR)
  SADF$VALOR<- ifelse(is.na(SADF$VALOR),0,SADF$VALOR)
  SADF<- SADF %>% filter(VALOR>1)
  ###########################################################################################################################################################
  SADF$VALOR_M2<-(SADF$VALOR/SADF$AREA)
  ###########################################################################################################################################################
  SADF$DESCRICAO<-str_to_upper(rm_accent(SADF$DESCRICAO))
  ###########################################################################################################################################################
  SADF$DESCRICAO_COMP<-str_to_upper(rm_accent(SADF$DESCRICAO_COMP))
  ###########################################################################################################################################################
  #SADF$PAGE_URL<-str_to_upper(rm_accent(SADF$PAGE_URL))
  ###########################################################################################################################################################
  #SADF$COD_ANUNCIO<-str_to_upper(rm_accent(SADF$COD_ANUNCIO))
  ###########################################################################################################################################################
  SADF$VALOR_LN<- log(SADF$VALOR)
  ###########################################################################################################################################################
  SADF$VALOR_M2_LN<-log(SADF$VALOR_M2)
  ###########################################################################################################################################################
  fotos= str_split(SADF$FOTOS,"li> <li",simplify = T)
  fotos=data.frame(fotos)
  
  
  for(i in 1:ncol(fotos)){
    fotos[,i]<- str_extract(fotos[,i],"src=\\\".*/\\>")
    fotos[,i]<- str_replace(fotos[,i],"src=\\\"","")
    fotos[,i]<- str_replace(fotos[,i],"\"/\\>","")
  }
  
  
  
  
  
  vetor=c("DATA_ID","TITULO","TIPO_ANUNCIO","LANCAMENTO","TIPO_IMOVEL","ENDERECO_COMP","ESTADO","CIDADE","BAIRRO","AREA","QUARTO","BANHEIRO","SUITE","VAGA","CONDOMINIO","IPTU","VALOR","VALOR_LN","VALOR_M2","VALOR_M2_LN","ANUNCIANTE","DESCRICAO","SCRAPING_TIME","LINK")
  
  TABELA_LIMPA<- SADF[,vetor]
  
  TABELA_LIMPA$SITE<- "VIVAREAL" 
  
  TABELA_LIMPA= cbind(TABELA_LIMPA,fotos)
  
  #TABELA_LIMPA<- TABELA_LIMPA %>% distinct(AREA,QUARTO,BANHEIRO,VALOR,.keep_all = T)
  TABELA_LIMPA<- TABELA_LIMPA %>% distinct(LINK,TIPO_ANUNCIO,.keep_all = T)
  
  names(TABELA_LIMPA)[c(6)]<-c("RUA_OU_QUADRA")
  
  TABELA_LIMPA <- TABELA_LIMPA %>% drop_na(c("RUA_OU_QUADRA","AREA","VALOR"))
  
  #SCRAPING_TIME:
  dia= str_split(Sys.Date(),"-",simplify = T)[1,3] 
  mes= str_split(Sys.Date(),"-",simplify = T)[1,2] 
  ano= str_split(Sys.Date(),"-",simplify = T)[1,1] 
  TABELA_LIMPA$DATA_SCRAPING <- paste0(dia,"/",mes,"/",ano)
  
  #tryCatch({
  #  dbWriteTable(con, "TABELA_GERAL42" , TABELA_LIMPA, append=T)
  #  print(paste0("A tabela inserida foi limpa e adicionada (com ",nrow(TABELA_LIMPA)," dados) à TABELA_GERAL_LIMPA no banco-teste"))
  #         },error=function(cond){
  #                     print("Erro ao inserir dados no SQL")
  #                     print(cond)})
  
  
  return(TABELA_LIMPA)
  
}



nome_base_suja = "base carapicuiba"

if(user == "Pupe"){
  #dados_sujo = read.csv2(paste0("C:/Users/Admin/Ermida/?caro Costa - Quadra Urbana/04 - Desenvolvimento/01 - Bases/Bases de Atualiza??o/",nome_base_suja,".csv"),sep = ",",encoding = "UTF-8")
  library(readxl)
  dados_sujo = read_xlsx('C:/Users/Admin/Ermida/?caro Costa - Quadra Urbana/03 - Clientes [Projetos]/QU/base suja dfi lotes DF140.xlsx')
}

if(user == "Rafael"){
  dados_sujo = read_excel('C:/Users/Ermida/Desktop/Ermida/?caro Costa - Quadra Urbana/03 - Clientes [Projetos]/WIZ/AVMs/2021WIZHOM167726/base suja brumadinho.xlsx')
  }
  #dados_sujo = read.csv2(paste0("C:/Users/jgararuna/Ermida/?caro Costa - Quadra Urbana/04 - Desenvolvimento/01 - Bases/Bases de Atualiza??o/",nome_base_suja,".csv"),sep = ",",encoding = "UTF-8")}

dados_sujo <- dados_sujo[,-1]
dados_sujo= cbind(DATA_ID=seq(1:nrow(dados_sujo)),dados_sujo)

tab_suja<-dados_sujo


dados_sujo$VALOR_ALUGUEL= ifelse(is.na(dados_sujo$VALOR_ALUGUEL),dados_sujo$VALOR_VENDA,dados_sujo$VALOR_ALUGUEL)
dados_sujo$VALOR_VENDA= ifelse(dados_sujo$VALOR_VENDA==dados_sujo$VALOR_ALUGUEL,NA,dados_sujo$VALOR_VENDA)


dados_limpo<-limp_bg_vvr_2(dados_sujo,"APARTAMENTO")

dados_limpo$ESTADO="DF"

dados_limpo<-TABELA_LIMPA

names(dados)
names(dados_sujo)


dados3<-bind_rows(dados_limpo,dados_limpo2)

nrow(dados)+nrow(dados_limpo)

dados<-dados2

write.xlsx2(dds,"base definitiva aps goi?nia (ALUGUEL E VENDA).xlsx")
getwd()


dados_limpo4<-bind_rows(dados_limpo,dados_limpo2,dados_limpo3)

dados_limpo3<- dados_limpo3 %>% distinct(CIDADE,AREA,QUARTO,BANHEIRO,VAGA,SUITE,VALOR,.keep_all = T)

dados_limpo3$DATA_ID= seq(1:nrow(dados_limpo3))

dados_limpo3$TIPO_ANUNCIO<- ifelse(is.na(dados_limpo3$TIPO_ANUNCIO),"LANCAMENTO",dados_limpo3$TIPO_ANUNCIO)

dados_limpo3<- dados_limpo3 %>% filter(str_detect(RUA_OU_QUADRA,"GAIVOTA"))


boxplot(dds$VAGA)




dados_limpo_t = dados_limpo %>% filter(str_detect(DESCRICAO,"TERRENO"))


write.csv2(dados_limpo_t,"terrenos saude sp.csv")
getwd()


ddsvendagoi=read.csv2("C:/Users/Admin/Ermida/?caro Costa - Quadra Urbana/03 - Clientes [Projetos]/QU/Aps Goi?nia/base definitiva aps goi?nia.csv")


ddsvendagoi$TIPO_ANUNCIO="VENDA"

ddsvendagoi=ddsvendagoi[,-1]



dds= bind_rows(ddsvendagoi,ddsalug[,1:25])

table(dds$ESTADO)

dds$ESTADO="GO"

sort(table(dados_limpo$BAIRRO))

ddsalug= dados_limpo %>% filter(TIPO_ANUNCIO=="ALUGUEL") %>% filter(VALOR_M2<=150)
boxplot(ddsalug$VALOR_M2)



names(dados_limpo)
dds=dds[,1:25]

















lotesDF140_dfi = limpeza_dfi_completa(dados_sujo2)


lotesDF140_vvr = limp_bg_vvr_2(dados_sujo,"LOTE")



lotesDF140=bind_rows(lotesDF140_dfi,lotesDF140_vvr)
write.xlsx2(lotesDF140,"lotesDF140.xlsx")
getwd()





