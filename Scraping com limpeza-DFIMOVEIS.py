#%%
from ast import Suite
#from termios import VDISCARD
from textwrap import dedent
from time import sleep
from typing import Sequence, Text
from numpy import NAN, dtype, expand_dims, log, unicode_
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import pandas as pd
import time, datetime, os
from csv import writer
import cloudscraper #faz a requisição pra receber os dados da pagina
from bs4 import BeautifulSoup #faz o tratamento do texto e extração por css
import re #para expressoes regulares
import timeit
from sqlalchemy import true
import unidecode
import re
import numpy as np
import math as mat



user="Pupe"
url = "https://www.dfimoveis.com.br/venda/df/brasilia/asa-norte/apartamento"
base_exportar="venda aps asa norte - dfimoveis - base limpa pelo python"




driver = webdriver.Chrome(executable_path='./chromedriver100')

imoveis_link_list = []

driver.get(url)
driver.maximize_window()
    
try:
    element = WebDriverWait(driver, 5).until(
       EC.presence_of_element_located((By.CLASS_NAME, "btn-cookie"))
    )
    element.click()
except:
    print("Sem conferência de coockies")


def iniciar_coleta():
    time.sleep(1)
    resultados = driver.find_element_by_class_name("property-list")
    imoveis = resultados.find_elements_by_class_name("gtm-imovel")
    numlinks= range(1,len(imoveis)+1)
    for i in numlinks:
        PAGE_URL = driver.find_element_by_xpath('/html/body/div[1]/section[3]/div[2]/ul/li[{}]/div/div[2]/div[2]/h3[1]/a'.format(i)).get_attribute("href")
        imoveis_link_list.append(PAGE_URL)
                    
    time.sleep(2)
    #return driver.find_element_by_link_text("Próxima Página >").is_enabled()

iniciar_coleta()

for i in range(300):
    try:
        proxima_pagina = driver.find_element_by_link_text("Próximo")
        proxima_pagina.click()
        time.sleep(5)
        iniciar_coleta()
    except:
        print("Sem próxima página")
        break
    time.sleep(5)

    
print(imoveis_link_list)
print(len(imoveis_link_list))


links=imoveis_link_list

scraper = cloudscraper.create_scraper()

imoveis_list=[]


##%% -> caso o scraping pare por falta de internet, ativar essa célula e rodar de novo
links=imoveis_link_list[len(imoveis_list):len(imoveis_link_list)]
scraper = cloudscraper.create_scraper()

for link in range(0,len(links)):
    content = scraper.get(links[link]).text
    soup = BeautifulSoup(content, 'html.parser')
     
    try:
        PAGE_URL = links[link]
    except:
        PAGE_URL = ""
    try:
        ENDERECO_COMP = soup.find("div",class_="col-9").text
    except:
        ENDERECO_COMP = ""
    try:
        GERAL = soup.find_all("div",class_="r-computador-dados")[1].text
    except:
        GERAL = ""
    try:
        DETALHES1 = soup.find_all("div",class_="col-md-12 bg-white shadow mt-2 pb-2")[0].text
    except:
        DETALHES1 = ""
    try:
        DETALHES = soup.find_all("div",class_="col-md-12 bg-white shadow mt-2 pb-2")[0].text
    except:
        DETALHES = ""
    try:
        ANUNCIANTE = soup.find_all("div",class_="col-md-8 mt-2 ml-2")[0].text
    except:
        ANUNCIANTE= ""
    try:
        FOTO1 = str(soup.find("div",class_="CarroselFotos"))
    except:
        FOTO1 = ""
    try:
        DESCRICAO_COMP = soup.find("p",class_="texto-descricao").text
    except:
        DESCRICAO_COMP = ''
    

    SCRAPING_TIME = datetime.datetime.now().strftime("%D %H:%M:%S")
    
    imoveis_dic = {
        'ENDERECO_COMP': ENDERECO_COMP,
        'GERAL': GERAL,
        'DETALHES1':DETALHES1,
        'DETALHES':DETALHES,
        'ANUNCIANTE': ANUNCIANTE,
        'FOTO1': FOTO1,
        'DESCRICAO_COMP': DESCRICAO_COMP,
        'SCRAPING_TIME': SCRAPING_TIME,
        'PAGE_URL': PAGE_URL,
    }
        
    imoveis_list.append(imoveis_dic)
    time.sleep(3)
    print("Pegou o imóvel {}: {}".format(len(imoveis_list),ENDERECO_COMP))

        

dds2 = pd.DataFrame(imoveis_list)


dds2_teste = dds2

# Criando a coluna DATA_ID
dds2_teste["DATA_ID"] = range(0,len(dds2_teste)) 

# Reordenando as colunas
cols = dds2_teste.columns.tolist() 
cols = cols[-1:] + cols[:-1]
dds2_teste = dds2_teste[cols]

# Renoameando o nome da coluna PAGE_URL para LINK
dds2_teste = dds2_teste.rename(columns={"PAGE_URL": "LINK"})
dds2_teste["LINK"] = dds2_teste["LINK"].str.lower()

for i in range(0,len(dds2_teste)):
    for j in range(0,len(dds2_teste.columns)):
        dds2_teste.iloc[i,j]=unidecode.unidecode(str(dds2_teste.iloc[i,j])).upper()

# Criando as colunas TIPO_IMOVEL e TIPO_ANUNCIO
TIPO = dds2_teste["DETALHES1"].str.split(" DE ", expand = True)
ANUNCIO = TIPO.iloc[:,0]
ANUNCIO = ANUNCIO.str.replace(" ","")
ANUNCIO = ANUNCIO.str.split("\\\r\\\n", expand = True).iloc[:,1].str.strip()
dds2_teste["TIPO_ANUNCIO"] = ANUNCIO



IMOVEL = TIPO.iloc[:,1].str.split("CODIGO", expand = True).iloc[:,0]
IMOVEL = IMOVEL.str.replace("(\\\n|\\\r)","").str.strip()
dds2_teste["TIPO_IMOVEL"] = IMOVEL



# Criando a coluna RUA_OU_QUADRA
dds2_teste["RUA_OU_QUADRA"] = dds2_teste["ENDERECO_COMP"].str.replace("\\\n", "").str.strip()

# Criando as colunas BAIRRO e CIDADE
CIDADE_BAIRRO = dds2_teste["GERAL"].str.split("CIDADE",expand = True).iloc[:,1]
CIDADE_BAIRRO = CIDADE_BAIRRO.str.split("\\\n\\\n\\\n\\\n\\\n", expand = True).iloc[:,0]
CIDADE_BAIRRO = CIDADE_BAIRRO.str.replace("(\\\n|\\\r|\\:)","").str.strip()
CIDADE_BAIRRO = CIDADE_BAIRRO.str.split(" - ", expand = True)
dds2_teste["CIDADE"] = CIDADE_BAIRRO.iloc[:,0]
dds2_teste["BAIRRO"] = CIDADE_BAIRRO.iloc[:, 1]

# Criando a coluna ESTADO
dds2_teste["ESTADO"] = pd.DataFrame([url])[0].str.split("/",expand = True).iloc[0,4]
dds2_teste["ESTADO"] = dds2_teste["ESTADO"].str.upper()

# Criando a coluna AREA
AREA = dds2_teste["GERAL"].str.split("AREA UTIL",expand = True)
AREA = AREA.iloc[:,1].str.split("(M2|HA)", expand = True).iloc[:,0]
AREA = AREA.str.replace("(\\\r|\\\n|\\:|R|\\$|\\/)", "").str.strip()
AREA = AREA.str.split(" A ", expand = True).iloc[:,0]
AREA = AREA.str.replace(".", "")
AREA = AREA.str.replace(",",".")
dds2_teste["AREA"] = AREA
dds2_teste["AREA"] = pd.to_numeric(dds2_teste["AREA"])
dds2_teste = dds2_teste.dropna(subset=["AREA"])

# LEMBRAR DE PEGAR AS AREAS > 0
dds2_teste = dds2_teste[ dds2_teste.AREA >= 1 ]
dds2_teste.index = range(0,len(dds2_teste))

# Criando a coluna VALOR e VALOR_LN
VALOR = dds2_teste["GERAL"].str.split("R\\$\\\r\\\n", expand = True).iloc[:,1]

VALOR = VALOR.str.split("AREA UTIL\\:\\\r\\\n", expand = True).iloc[:,0]

VALOR = VALOR.str.replace("(A PARTIR|SIMULAR CREDITO|SOB CONSULTA|\\\r|\\\n|\\:)", "").str.strip()
VALOR = VALOR.str.replace(".", "")
VALOR = VALOR.str.replace(",",".")

dds2_teste["VALOR"] = VALOR
dds2_teste["VALOR"] = pd.to_numeric(dds2_teste["VALOR"])
dds2_teste["VALOR_LN"] = log(dds2_teste["VALOR"])

# Criando a coluna VALOR_M2 e VALOR_M2_LN
dds2_teste["VALOR_M2"] = dds2_teste["VALOR"]/dds2_teste["AREA"]
dds2_teste["VALOR_M2_LN"] = log(dds2_teste["VALOR_M2"])

# CRIANDO A COLUNA DE QUARTO
QUARTO = dds2_teste["GERAL"].str.split("AREA UTIL", expand = True).iloc[:,1]
QUARTO = QUARTO.str.split("CIDADE", expand = True).iloc[:,0]
QUARTO = QUARTO.str.replace("(\\\n|\\\r)"," ")
QUARTO = QUARTO.str.extract("(...QUARTO)")[0].str.replace("QUARTO","").str.strip()
dds2_teste["QUARTO"] = QUARTO
dds2_teste["QUARTO"] = pd.to_numeric(dds2_teste["QUARTO"])

# CRIANDO A COLUNA DE SUITE
SUITE = dds2_teste["GERAL"].str.split("AREA UTIL", expand = True).iloc[:,1]
SUITE = SUITE.str.split("CIDADE", expand = True).iloc[:,0]
SUITE = SUITE.str.replace("(\\\n|\\\r)"," ")
SUITE = SUITE.str.extract("(...SUITE)")[0].str.replace("SUITE","").str.strip()
dds2_teste["SUITE"] = SUITE
dds2_teste["SUITE"] = pd.to_numeric(dds2_teste["SUITE"])

# CRIANDO A COLUNA DE VAGA
VAGA = dds2_teste["GERAL"].str.split("AREA UTIL", expand = True).iloc[:,1]
VAGA = VAGA.str.split("CIDADE", expand = True).iloc[:,0]
VAGA = VAGA.str.replace("(\\\n|\\\r)"," ")
VAGA = VAGA.str.extract("(...VAGA)")[0].str.replace("VAGA","").str.strip()
dds2_teste["VAGA"] = VAGA
dds2_teste["VAGA"] = pd.to_numeric(dds2_teste["VAGA"])

# Criando coluna BANHEIRO
dds2_teste["BANHEIRO"] = 0

# Criando coluna IPTU
dds2_teste["IPTU"] = 0

# Criando coluna CONDOMINIO
CONDOMINIO = dds2_teste["GERAL"]
#CONDOMINIO = CONDOMINIO.str.split("AREA UTIL", expand = True).iloc[:,1]
#CONDOMINIO = CONDOMINIO.str.split("CIDADE", expand = True).iloc[:,0]
#CONDOMINIO = CONDOMINIO.str.replace("\\\r\\\n"," ")
#CONDOMINIO = CONDOMINIO.str.extract("(CONDOMINIO.*CIDADE)")[0].str.replace("CONDOMINIO","").str.strip()
#CONDOMINIO = CONDOMINIO.str.replace("(\\\n|\\\r)"," ").str.strip()
#dds2_teste["CONDOMINIO"] = CONDOMINIO
#dds2_teste["CONDOMINIO"] = pd.to_numeric(dds2_teste["CONDOMINIO"])

dds2_teste["CONDOMINIO"]=0

# Criando a coluna DESCRICAO
dds2_teste["DESCRICAO"] = dds2_teste["DESCRICAO_COMP"].str.replace("\\\n", "").str.strip()

# Criando a coluna DATA_SCRAPING
dds2_teste["DATA_SCRAPING"] = dds2_teste["SCRAPING_TIME"].str.split(" ",expand = True).iloc[:,0]

# Estruturando coluna SCRAPING_TIME
dds2_teste["SCRAPING_TIME"] = dds2_teste["SCRAPING_TIME"].str.split(" ",expand = True).iloc[:,1]

# Criando a coluna SITE
dds2_teste["SITE"] = "DFIMOVEIS"

# Criando a coluna TITULO
dds2_teste["TITULO"] = dds2_teste["ENDERECO_COMP"].str.replace("\\\n", "").str.strip()

# Renomeando o nome da coluna FOTO1 para FOTOS
dds2_teste = dds2_teste.rename(columns={"FOTO1": "FOTOS"})
dds2_teste["FOTOS"] = dds2_teste["FOTOS"].str.lower()

# Criando a coluna ANUNCIANTE
dds2_teste["ANUNCIANTE"] = dds2_teste["ANUNCIANTE"].str.replace("\\\n"," ")

# Retirando as duplicadas
dds2_teste = dds2_teste.drop_duplicates(subset=["LINK"])
dds2_teste = dds2_teste.drop_duplicates(subset=["VALOR","AREA","BAIRRO"])

# Retirando os NA's
dds2_teste = dds2_teste.dropna(subset=["VALOR"])
dds2_teste = dds2_teste.dropna(subset=["AREA"])
dds2_teste = dds2_teste.dropna(subset=["RUA_OU_QUADRA"])

# Reordenando as colunas do banco
dds3 = dds2_teste[["DATA_ID","TITULO","TIPO_ANUNCIO","TIPO_IMOVEL","RUA_OU_QUADRA","ESTADO","CIDADE","BAIRRO","AREA","QUARTO","BANHEIRO","SUITE","VAGA","CONDOMINIO","IPTU","VALOR","VALOR_LN","VALOR_M2","VALOR_M2_LN","ANUNCIANTE","DESCRICAO","DATA_SCRAPING","SCRAPING_TIME","FOTOS","LINK"]]


if user == "Pupe":
    dds3.to_excel('C:/Users/Admin/Ermida/Ícaro Costa - Quadra Urbana/03 - Clientes [Projetos]/QU/{}.xlsx'.format(base_exportar))

if user == "Rafael":
    dds3.to_excel('C:/Users/Ermida/OneDrive - Ermida/Quadra Urbana/03 - Clientes [Projetos]/QU/{}.xlsx'.format(base_exportar))

# %%
len(imoveis_list)
# %%
dds2_teste["GERAL"][653]
# %%
