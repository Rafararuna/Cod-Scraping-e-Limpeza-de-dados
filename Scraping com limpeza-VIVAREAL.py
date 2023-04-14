#%%
from time import sleep
from typing import Sequence, Text
from numpy import NAN, dtype, log, unicode_
import selenium
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
import unidecode
import re
import numpy as np
import math as mat

#%%
user= "Rafael"

url= "https://www.vivareal.com.br/imoveis-lancamento/sao-paulo/zona-sul/moema/apartamento_residencial/"


#base_exportar="imóveis a venda em itaim bibi SP area-ate=75 - base limpa pelo python"
base_exportar="imoveis novos moema - vvr - base limpa pelo python"


#%%

tic1 = timeit.default_timer()

driver = webdriver.Chrome(executable_path='./chromedriver103')

imoveis_link_list = []

driver.get(url)
    
try:
    element = WebDriverWait(driver, 5).until(
       EC.presence_of_element_located((By.ID, "cookie-notifier-cta"))
    )
    element.click()
except:
    print("Sem conferência de coockies")



def iniciar_coleta():   
    time.sleep(1)
    resultados = driver.find_element_by_class_name("results-list")
    imoveis = resultados.find_elements_by_tag_name("article")
    for imovel in imoveis:
        PAGE_URL = imovel.find_element_by_class_name("property-card__content-link.js-card-title").get_attribute("href")
        imoveis_link_list.append(PAGE_URL)
                    
    time.sleep(3)


iniciar_coleta()

for i in range(300):
    try:
        proxima_pagina = driver.find_element_by_partial_link_text("Próxima")
        proxima_pagina.click()
        time.sleep(5)
        iniciar_coleta()
    except:
        print("Sem próxima página")
        break
    time.sleep(5)

    
print(imoveis_link_list)
print(len(imoveis_link_list))

links=imoveis_link_list[0:len(imoveis_link_list)]

toc1 = timeit.default_timer()

print(toc1-tic1)

tic2 = timeit.default_timer()

imoveis_list=[]
lista_links_inaces=[]


#links=imoveis_link_list[(5550+2300):len(imoveis_link_list)]
scraper = cloudscraper.create_scraper()

for i in range(0,len(links)):
    content = scraper.get(links[i]).text
    soup = BeautifulSoup(content, 'html.parser')
    
    try:
        TITULO= soup.find("h1",class_="title__title js-title-view").text
    except:
        TITULO = ''
    try:
        PAGE_URL= links[i]
    except:
        PAGE_URL = ""
    try:
        ENDERECO_COMP= soup.find("div",class_="title__address-wrapper").text
    except:
        ENDERECO_COMP = ""
    try:
        AREA=soup.find("li",class_="features__item features__item--area js-area").text
    except:
        AREA = ""
    try:
        QUARTO= soup.find("li",class_="features__item features__item--bedroom js-bedrooms").text
    except:
        QUARTO = ""
    try:
        BANHEIRO = soup.find("li",class_="features__item features__item--bathroom js-bathrooms").text
    except:
        BANHEIRO = ""
    try:
        SUITE=soup.find("small",class_="features__extra-info").text
    except:
        SUITE= ''
    try:
        VAGA=soup.find("li",class_="features__item features__item--parking js-parking").text
    except:
        VAGA = ''
    try:
        ANUNCIANTE= soup.find("a",class_="publisher__name")
        ANUNCIANTE= str(ANUNCIANTE)
    except:
        ANUNCIANTE = ''
    try:
        VALOR_VENDA= soup.find("h3",class_="price__price-info js-price-sale").text
    except:
        VALOR_VENDA = ''
    try:
        VALOR_ALUGUEL= soup.find("h3",class_="price__price-info js-price-rent").text
    except:
        VALOR_ALUGUEL = ''    
    try:
        DESCRICAO= soup.find("h3",class_="description__title js-description-title").text
    except:
        DESCRICAO = ''
    try:
        DESCRICAO_COMP=soup.find("p",class_="description__text").text
    except:
        DESCRICAO_COMP = ''
    
    try:
        list_links_fotos=soup.find_all("ul",class_="carousel__container js-carousel-scroll")
        FOTOS = str(list_links_fotos)
    except:
        FOTOS = ''
        
    try:
        CONDOMINIO=soup.find("span",class_="price__list-value condominium js-condominium").text
    except:
        CONDOMINIO = ''
    try:    
        IPTU=soup.find("li",class_="price__list-value iptu js-iptu").text
    except:
        IPTU = ''
        
    SCRAPING_TIME = datetime.datetime.now().strftime("%D %H:%M:%S")
    
    imoveis_dic = {
        'TITULO': TITULO,
        'ENDERECO_COMP': ENDERECO_COMP,
        'AREA': AREA,
        'QUARTO': QUARTO,
        'BANHEIRO': BANHEIRO,
        'SUITE': SUITE,
        'VAGA': VAGA,
        'CONDOMINIO': CONDOMINIO,
        'IPTU': IPTU,
        'ANUNCIANTE': ANUNCIANTE, 
        'VALOR_VENDA': VALOR_VENDA,
        'VALOR_ALUGUEL': VALOR_ALUGUEL,
        'DESCRICAO': DESCRICAO,
        'DESCRICAO_COMP': DESCRICAO_COMP,
        'FOTOS': FOTOS,
        'SCRAPING_TIME': SCRAPING_TIME,
        'PAGE_URL': PAGE_URL,
    }
        
    imoveis_list.append(imoveis_dic)
    print("pegou um imóvel {}, com título:{}".format(i+1,TITULO))
    time.sleep(3)


dds = pd.DataFrame(imoveis_list)  


toc2 = timeit.default_timer()

print(toc2-tic2)

#ddssss=pd.read_excel('C:/Users/Admin/Ermida/Ícaro Costa - Quadra Urbana/03 - Clientes [Projetos]/QU/imóveis a venda em campo-belo SP area-ate=230 area-desde=151 - base suja.xlsx')
#ddssss=ddssss.iloc[:,1:len(ddssss.columns)]

dds1=dds

dds1["DATA_ID"] = range(0,len(dds1))
dds1.columns= ["TITULO","ENDERECO_COMP","AREA","QUARTO","BANHEIRO","SUITE","VAGA","CONDOMINIO","IPTU","ANUNCIANTE","VALOR_VENDA","VALOR_ALUGUEL","DESCRICAO","DESCRICAO_COMP","FOTOS","SCRAPING_TIME","LINK","DATA_ID"]

for i in range(0,len(dds1)):
    for j in range(0,len(dds1.columns)):
        dds1.iloc[i,j]=unidecode.unidecode(str(dds1.iloc[i,j])).upper()

dds1["VALOR"]=""
dds1["TIPO_ANUNCIO"]=""

tamanho= len(dds1)

t_a=pd.DataFrame([url]).iloc[:,0].str.extract("(vivareal\\.com\\.br.*\\/)").iloc[:,0].str.split("\\/",expand=True).iloc[0,1]

if t_a == 'imoveis-lancamento':
    t_a = "venda"

if t_a == "venda":
    for i in range(0,tamanho-1):
        if dds1["VALOR_ALUGUEL"][i] != '':
            tam=len(dds1)

            dds1.loc[tam]= list(dds1.iloc[i,:])
            dds1["VALOR"][tam] =  dds1["VALOR_ALUGUEL"][tam]
            dds1["TIPO_ANUNCIO"][tam]= "ALUGUEL"

            dds1["VALOR"][i]= dds1["VALOR_VENDA"][i]

        if dds1["VALOR_ALUGUEL"][i] == '':
            dds1["VALOR"][i]= dds1["VALOR_VENDA"][i]
            dds1["TIPO_ANUNCIO"][i]= "VENDA"
    
        if dds1["TIPO_ANUNCIO"][i] == '':
            dds1["TIPO_ANUNCIO"][i] = "VENDA"

if t_a == "aluguel":
    for i in range(0,tamanho-1):
        if dds1["VALOR_ALUGUEL"][i] != '': # nesse caso VALOR_VENDA = valordealuguel e VALOR_ALUGUEL = valordevenda
            tam=len(dds1)

            dds1.loc[tam]= list(dds1.iloc[i,:])
            dds1["VALOR"][tam] =  dds1["VALOR_ALUGUEL"][tam]
            dds1["TIPO_ANUNCIO"][tam]= "ALUGUEL"

            dds1["VALOR"][i]= dds1["VALOR_VENDA"][i]

        if dds1["VALOR_ALUGUEL"][i] == '':
            dds1["VALOR"][i]= dds1["VALOR_VENDA"][i]
            dds1["TIPO_ANUNCIO"][i]= "ALUGUEL"
        
        if dds1["TIPO_ANUNCIO"][i] == '':
            dds1["TIPO_ANUNCIO"][i] = "VENDA"


dds1["TIPO_IMOVEL"]=dds1["TITULO"].str.extract(pat='(LOTE\\/TERRENO|PREDIO COMERCIAL|FAZENDA\\/SITIO|LOTE RESIDENCIAL|CASA CONDOMINIO|LOTE COMERCIAL|PONTO COMERCIAL|GALPAO\\/DEPOSITO\\/ARMAZEM|CHACARA|FLAT|HOTEL|SALA CLINICA|KITNET|COBERTURA|CASA SOBRADO|PREDIO RESIDENCIAL|GARAGEM|LOJA|SALA COMERCIAL|SOBRADO|IMOVEL COMERCIAL|CONSULTORIO|KITNET KITNET-STUDIO|APARTAMENTO DUPLEX|SALA|KITNET MOBILIADO|CASA DE CONDOMINIO|CASAS DE CONDOMINIO|APARTAMENTO COBERTURA|HOTEL FLAT|LOJA SOBRELOJA|GALPAO|APARTAMENTO LOFT|PREDIO MISTO|PONTO COMERCIAL GALPAO|SALA CONSULTORIO|APARTAMENTO MOBILIADO|CASA CONDOMINIO SOBRADO|SALA ANDAR|PONTO COMERCIAL PREDIO|PONTO COMERCIAL HOTEL|LOTE INDUSTRIAL|PONTO COMERCIAL PADARIA|PONTO COMERCIAL POSTO DE GASOLINA|CASA BARRACAO|PONTO COMERCIAL POUSADA|APARTAMENTO TRIPLEX|PONTO COMERCIAL FARMACIA|CASA|APARTAMENTO)')

dds1["TIPO_IMOVEL"] = dds1["TIPO_IMOVEL"].fillna("LANCAMENTO")

dds1 = dds1[ dds1.ENDERECO_COMP != '' ]

dds1.index = range(0,len(dds1))

dds1["ENDERECO_COMP"]= dds1["ENDERECO_COMP"].str.replace(" VER NO MAPA","")

dds1["ESTADO"] = dds1["ENDERECO_COMP"].str.extract("(...$)")

cidade=dds1["ENDERECO_COMP"].str.extract("(.*\\-)")
cidade.iloc[:,0] = "-"+cidade.iloc[:,0]
cidade=cidade.iloc[:,0].str.split(",")

cidade2=[]

for i in range(0,len(dds1)):
    cidade2.append(str(cidade[i][len(cidade[i])-1]))


dds1["CIDADE"]=cidade2
dds1["CIDADE"] = dds1["CIDADE"].str.replace("-","")
dds1["CIDADE"] = dds1["CIDADE"].str.strip()

BAIRRO=dds1["ENDERECO_COMP"].str.extract("(.*\\,)")
BAIRRO.iloc[:,0] = " - "+BAIRRO.iloc[:,0]
BAIRRO=BAIRRO.iloc[:,0].str.split("-")

BAIRRO2=[]
for i in range(0,len(dds1)):
    try:
        BAIRRO2.append(str(BAIRRO[i][len(BAIRRO[i])-1]))
    except:
        BAIRRO2.append(" ")

dds1["BAIRRO"]=BAIRRO2
dds1["BAIRRO"] = dds1["BAIRRO"].str.replace(",","")
dds1["BAIRRO"] = dds1["BAIRRO"].str.strip()

area= dds1["AREA"].str.replace("M2","")
area = area.str.split("a", expand = True)
dds1["AREA"] = area.iloc[:,0].str.strip()
dds1["AREA"] = pd.to_numeric(dds1["AREA"],errors = 'coerce')

QUARTO= dds1["QUARTO"].str.replace("QUARTO","")
QUARTO= QUARTO.str.replace("S","")
QUARTO = QUARTO.str.split("a", expand = True)
dds1["QUARTO"] = QUARTO.iloc[:,0].str.strip()
dds1['QUARTO'] = pd.to_numeric(dds1['QUARTO'],errors = 'coerce')

SUITE= dds1["SUITE"].str.replace("SUITE","")
SUITE= SUITE.str.replace("S","")
SUITE = SUITE.str.split("a", expand = True)
dds1["SUITE"] = SUITE.iloc[:,0].str.strip()
dds1['SUITE'] = pd.to_numeric(dds1['SUITE'],errors = 'coerce')

BANHEIRO = dds1["BANHEIRO"].str.strip().str.split(" ", expand = True)
BANHEIRO = BANHEIRO.iloc[:,0].str.strip()
BANHEIRO = pd.to_numeric(BANHEIRO,errors = 'coerce')
dds1['BANHEIRO']=BANHEIRO

VAGA = dds1["VAGA"].str.strip().str.split(" ", expand = True)
VAGA = VAGA.iloc[:,0].str.strip()
VAGA = pd.to_numeric(VAGA,errors = 'coerce')
dds1['VAGA']=VAGA

condo= dds1["CONDOMINIO"].str.replace("R\\$","")
condo = condo.str.replace("\\.","")
condo = condo.str.replace(",","\\.")
condo = pd.to_numeric(condo,errors = 'coerce')
dds1['CONDOMINIO']=condo

IPTU= dds1["IPTU"].str.replace("R\\$","")
IPTU = IPTU.str.replace("\\.","")
IPTU = IPTU.str.replace(",","\\.")
IPTU = pd.to_numeric(IPTU,errors = 'coerce')
dds1['IPTU']=IPTU

VALOR= dds1["VALOR"]
VALOR= VALOR.str.replace("R\\$","")
VALOR= VALOR.str.replace("\\.","")
VALOR= VALOR.str.replace("\\,",".")
VALOR= VALOR.str.replace("\\/MES","")
VALOR= VALOR.str.strip()

dds1["VALOR"] = pd.to_numeric(VALOR,errors = 'coerce')

dds1["VALOR_M2"] = dds1["VALOR"]/dds1["AREA"]

dds1["VALOR_LN"] = log(dds1["VALOR"])
dds1["VALOR_M2_LN"] = log(dds1["VALOR_M2"])

fts=dds1["FOTOS"].str.split("</LI> <LI",expand=True)

for j in range(0,len(fts.columns)):
    fts.iloc[:,j]=fts.iloc[:,j].str.extract("( SRC=\"HTTPS\\:\\/\\/RESIZEDIMGS.*JPG)")
    fts.iloc[:,j]=fts.iloc[:,j].str.replace(" SRC=\"","").str.lower()

dds1["FOTOS"] = fts.iloc[:,0]

dds1["LINK"]=dds1["LINK"].str.lower()

dds1 = dds1.drop_duplicates(subset=["LINK","TIPO_ANUNCIO"])

dds1.index = range(0,len(dds1))

data = dds1["SCRAPING_TIME"].str.split(" ",expand=True).iloc[:,0].str.split("/",expand=True)
dds1["DATA_SCRAPING"]=""
for i in range(0,len(dds1)):
    dds1["DATA_SCRAPING"][i]= "{}/{}/{}".format(data.iloc[i,0],data.iloc[i,1],data.iloc[i,2])
dds1["DATA_SCRAPING"]

dds1["SCRAPING_TIME"]= dds1["SCRAPING_TIME"].str.split(" ",expand=True).iloc[:,1]

dds2=dds1[["DATA_ID","TITULO","TIPO_ANUNCIO","TIPO_IMOVEL","ENDERECO_COMP","ESTADO","CIDADE","BAIRRO","AREA","QUARTO","BANHEIRO","SUITE","VAGA","CONDOMINIO","IPTU","VALOR","VALOR_LN","VALOR_M2","VALOR_M2_LN","ANUNCIANTE","DESCRICAO","DATA_SCRAPING","SCRAPING_TIME","FOTOS","LINK"]]
dds2["SITE"]= "VIVAREAL"

dds2=dds2.rename(columns={"ENDERECO_COMP":"RUA_OU_QUADRA"})

dds2= dds2.dropna(subset=["VALOR"])
dds2= dds2.dropna(subset=["AREA"])
dds2= dds2.dropna(subset=["RUA_OU_QUADRA"])

dds2["DATA_ID"] = range(1,len(dds2)+1)
dds2.index = range(1,len(dds2)+1)

dds2["DESCRICAO_COMP"]= " "

if user == "Pupe":
    dds2.to_excel('C:/Users/Admin/Ermida/Ícaro Costa - Quadra Urbana/03 - Clientes [Projetos]/QU/{}.xlsx'.format(base_exportar))

if user == "Rafael":
    dds2.to_excel('C:/Users/Ermida/OneDrive - Ermida/Quadra Urbana/03 - Clientes [Projetos]/QU/{}.xlsx'.format(base_exportar))

# %%
dds = pd.DataFrame(imoveis_list) 
dds
# %%
