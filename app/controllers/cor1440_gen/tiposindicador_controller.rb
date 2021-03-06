# encoding: UTF-8
require_dependency "cor1440_gen/concerns/controllers/tiposindicador_controller"

module Cor1440Gen
  class TiposindicadorController < Sip::ModelosController
    include Cor1440Gen::Concerns::Controllers::TiposindicadorController


    def atributos_index
      [ "id", 
        "nombre",
        "medircon",
        "esptipometa",
        "campotind",
        "desc20",
        "desc40",
        "desc80",
        "desc100",
        "espvaloresomision",
        "espvalidaciones",
        "espfuncionmedir" ]
    end

    def lista_params
      lista_params_gen + [ :pprogtind_attributes => [
        :id,
        :fase,
        :porcentaje ]
      ]
    end

    def update
      if params[:tipoindicador] && params[:tipoindicador][:campotind_attributes]
        params[:tipoindicador][:campotind_attributes].each do |p| 
          if p[1]['_destroy'] == "1" && p[1][:id].to_i > 0
            ::EfectoValorcampotind.where(valorcampotind_id: p[1][:id]).destroy_all
            Cor1440Gen::Valorcampotind.where(campotind_id: p[1][:id]).destroy_all
          end
        end
      end
      update_gen
    end

  end
end
