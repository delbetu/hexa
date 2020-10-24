- [ ] Cuando hay un raise unauthorized la api de graphql devuelve un html espantoso
- [ ] Mejorar la estrategia de logs. (hacer que todo se loguee en 'log/<environment.log>')
- [ ] [Implementar] hacer un recurso job_post considerando que los external_collaborator colaboran con un internal_hr (pertenecen al mismo team)
      y testear reglas de acceso:

* los external_collaborator pueden crearlos
* los guest solo puede leer
* los candidate pueden aplicar
* los hr pueden modificar los creados por los teams que el pertenece
  read -> [ guest, candidate, external_collaborator, internal_hr ]
  create -> [ external_collaborator, internal_hr ] within the same team
  update -> [ external_collaborator, internal_hr ] within the same team
  delete -> [ external_collaborator, internal_hr ] within the same team
  apply -> [ candidate ]

- [ ] Grabar una implementacion demo mostrando como se programa con hexa, partiendo de la definicion de un caso de uso.
- [ ] User is identified by email in many places. Lets replace that with a uuid
- [ ] Crear un Reporter que encapsule Raven ( Sentry ) y el logger de heroku??, que sea visible de todos lados??
- [ ] test sign_up user creator adapter
- [ ] test sign_up email confirmator adapter
- [ ] deploy a servidor gratis diferente de heroku https://dev.to/vuelancer/free-deployment-providers-bk0
- [ ] No utilizar coverage en development
