import requests
from pathlib import Path
import os
import questionary
from parsel.selector import Selector



def make_session():
    session = requests.Session()
    headers = {
        'authorization': 'Bearer ...',  # Substitua pelo seu token de autenticação
        'origin': 'https://www.estrategiaconcursos.com.br',
        'referer': 'https://www.estrategiaconcursos.com.br/',
    }
    session.headers.update(headers)
    return session

def extrair_pdf_real(html_text):
    from parsel.selector import Selector
    selector = Selector(text=html_text)
    content = selector.css('meta[http-equiv="refresh"]::attr(content)').get()
    if not content:
        raise Exception("Tag meta refresh não encontrada")
    url_part = content.split('url=')[-1].strip()
    redirect_url = url_part.strip("'\"")
    return redirect_url

def selecionar_curso(cursos):
    opcoes = [f"{curso['titulo']}::{idx}" for idx, curso in enumerate(cursos)]
    escolha = questionary.select("Selecione um curso:", choices=opcoes).ask()
    idx_escolhido = int(escolha.split("::")[-1])
    return cursos[idx_escolhido]

def selecionar_materias(course):
    opcoes = [f"{materia['nome']}::{materia['id']}" for materia in course["cursos"]]
    escolhas = questionary.checkbox("Selecione as matérias:", choices=opcoes).ask()
    return [(int(item.split("::")[-1]), item.split("::")[0]) for item in escolhas]

def main():
    base_url = "https://api.estrategiaconcursos.com.br/api"
    session = make_session()
    user_courses_data = session.get(f'{base_url}/aluno/curso').json()

    cursos_matriculados = user_courses_data["data"]["concursos"]
    curso_escolhido = selecionar_curso(cursos_matriculados)
    course_title = curso_escolhido["titulo"]
    print(f"Curso selecionado: {course_title}")

    materias_escolhidas = selecionar_materias(curso_escolhido)

    for materia_id, materia_title in materias_escolhidas:
        materias_aulas_data = session.get(f"{base_url}/aluno/curso/{materia_id}").json()
        aulas = materias_aulas_data["data"]["aulas"]

        for aula_index, aula in enumerate(aulas):
            aula_title = aula["nome"]
            aula_pdf_url = aula["pdf"]

            if aula_pdf_url:
                aula_html = session.get(aula_pdf_url)
                pdf_real_url = extrair_pdf_real(aula_html.text)
                pdf_bytes = session.get(pdf_real_url).content

                path = Path(f"./{course_title}/{materia_title}/{aula_index:03d} - {aula_title}.pdf")
                os.makedirs(path.parent, exist_ok=True)
                print(f"Baixando [{materia_title}] aula {aula_index + 1}/{len(aulas)}: {aula_title}")
                with path.open("wb") as f:
                    f.write(pdf_bytes)

if __name__ == "__main__":
    main()
