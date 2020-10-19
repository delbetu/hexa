- [ ] Cuado la api recibe un token tiene que pedirle al authorizer que guarde el user context (hace como un sign in y guarda las credenciales del usuario en el user_context)
- [ ] WIP Mandar token por graphql https://www.howtographql.com/graphql-ruby/4-authentication/
- [ ] Mejorar la estrategia de logs. (hacer que todo se loguee en 'log/<environment.log>')
- [ ] Agregar folder prototype: que es donde irian los crud agarrado a graphql ( esto tiene que tener un generador de codigo asi es facil tener algo pronto en 2 minutos )
- [ ] [Implementar] cuando viene una peticion que precisa autorizacion, desencodiar el token, y verificar si tiene acceso a la peticion actual
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
- [x] Representar los roles siempre como strings (en algunos lados estan como symbols)
- [x] GH hook para hacer autodeploy de master branch
- [x] Crear generador de crud
- [x] Error deploy production
      2020-10-11T21:46:36.403800+00:00 app[web.1]: NameError: uninitialized constant Rack::GraphiQL
      2020-10-11T21:46:36.403802+00:00 app[web.1]: Did you mean? GraphQL
      2020-10-11T21:46:36.403803+00:00 app[web.1]: /app/config.ru:7:in `block (2 levels) in <main>'
