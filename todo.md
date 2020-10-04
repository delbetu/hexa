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
- [ ] Crear un Reporter que encapsule Raven ( Sentry ) y el logger de heroku??, que sea visible de todos lados??
- [ ] test sign_up user creator adapter
- [ ] test sign_up email confirmator adapter
- [ ] deploy a servidor gratis diferente de heroku https://dev.to/vuelancer/free-deployment-providers-bk0
- [x] Test email confirmation endpoint with db and gql
- [x] merge MyAuthorizer with shared authorizer
- [x] Test domain invitation
- [x] test use case action ConfirmInvitation
- [X] Manual testing email confirmation
