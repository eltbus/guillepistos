# TL; DR

Graduado en Ciencias Físicas con 4 años de experiencia en el mundo de la programación.

Apasionado de Linux y la terminal. Todo lo que quiero aprender se puede hacer ahí.

## Experiencia

<!-- experience -->
{% if cv %}
<ol reversed>
{% for experience in cv.experiences -%}
    <li>{{ experience.title }} at {{ experience.name }}</li>
        <ul>
            {% for milestone in experience.milestones -%}
              <li>{{ milestone }}</li>
            {% endfor -%}
        </ul>
{% endfor -%}
</ol>
{% endif %}
<!-- experience -->

## Habilidades
<!-- skills -->
{% if cv %}
{% for skill in cv.skills -%}
=== "{{ skill.name }}"
    <ul>
    {% for content in skill.content -%}
        {% if content.extra %}
            <li>{{ content.name }}: {{ content.extra }}</li>
        {% else %}
            <li>{{ content.name }}</li>
        {% endif %}
    {% endfor -%}
    </ul>
{% endfor -%}
{% endif %}
<!-- skills -->

## Idiomas
<!-- languages -->
{% if cv %}
{% for language in cv.languages -%}
<ul>
  <li>{{ language.name }} ({{ language.level }})</li>
</ul>
{% endfor -%}
{% endif %}
<!-- languages -->

## Educacion
<!-- education -->
{% if cv %}
{% for i in cv.education -%}
<ul>
  <li>{{ i.name }} ({{ i.institution }})</li>
</ul>
{% endfor -%}
{% endif %}
<!-- education -->
