# encoding: UTF-8
require_dependency "sip/concerns/controllers/actoressociales_controller"

module Sip
  class ActoressocialesController < Sip::ModelosController
    include Sip::Concerns::Controllers::ActoressocialesController

    def atributos_index
      [ :id, 
        :grupoper_id,
        :nivelrelacion_id
      ] +
      [ :sectoractor_ids =>  [] ] +
      [ :regiongrupo_ids =>  [] ] +
      [ :grupo_ids =>  [] ] +
      [ :lineabase20182020,
        :habilitado,
        :created_at
      ]
    end

    def atributos_show
      [
        :id, 
        :grupoper_id,
      ] +
      [ :sectoractor_ids =>  [] ] +
      [:pais_id] +
      [ :regiongrupo_ids =>  [] ] +
      [ :grupo_ids =>  [] ] +
      [ 
        :lineabase20182020,
        :personacontacto,
        :cargo,
        :correo,
        :telefono,
        :fax,
        :celular,
        :direccion,
        :created_at,
        :fechadeshabilitacion_localizada
      ]
    end

    def atributos_form
      a = atributos_show - ['id', :id, :created_at, :updated_at]
      if cannot? :manage, :lineabase20182020
        a = a - ["lineabase20182020", :lineabase20182020]
      end
      a[a.index(:grupoper_id)] = :grupoper
      return a
    end

    def index_reordenar(registros)
      return registros.joins(:grupoper).reorder('sip_grupoper.nombre')
        #'JOIN sip_grupoper ON sip_grupoper.id=sip_actorsocial.grupoper_id')
        #reorder('sip_grupoper.nombre')
    end


    def self.filtra_grupos_fecha(c, grupo_ids, fecha)
      gid_dir = Sip::Grupo.where(nombre: 'Dirección').take
      gid_dir = gid_dir ? gid_dir.id : -1
      if grupo_ids && grupo_ids.length > 0 && !grupo_ids.include?(gid_dir)
        c = c.where("sip_actorsocial.id IN 
                     (SELECT actorsocial_id 
                      FROM actorsocial_grupo WHERE
                      grupo_id IN (#{grupo_ids.join(',')}))")
      end
      if fecha
        c = c.where(
          '(? <= fechadeshabilitacion OR fechadeshabilitacion IS NULL) ', fecha)
      end

      return c
    end

    def actorsocial_params
      params.require(:actorsocial).permit(
        atributos_form - [:grupoper] +
        [ :pais_id,
          :grupoper_attributes => [
            :id,
            :nombre,
            :anotaciones ]
      ]) 
    end

  end
end