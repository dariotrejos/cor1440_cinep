# You can use CoffeeScript in this file: http://coffeescript.org/

#//= require sip/motor
#//= require heb412_gen/motor
#//= require jquery-ui/widgets/autocomplete
#//= require cocoon


@reconocer_decimal_locale_es_CO = (n) ->
  if n == ""
    return 0
  i = 0
  r = ""
  while i<n.length
    if n[i] == ','
      r = r + '.'
    if n[i] >= '0' && n[i] <='9'
      r = r + n[i]
    i++
  return parseFloat(r)

@recalcula_aemergente_pesos_localizado = (campo, tasa) ->
  vc = $('#' + campo).val()
  if typeof vc != 'undefined' && vc != '' && typeof tasa != 'undefined' && tasa > 0
      vcp = reconocer_decimal_locale_es_CO(vc)*tasa
      vcpl = new Intl.NumberFormat('es-CO').format(vcp)
      $('#' + campo).attr('title', '$ ' + vcpl).tooltip('fixTitle').tooltip('show')

@establece_duracion = (root, obdur) ->
  $('#proyectofinanciero_duracion').val(obdur.duracion)

@recalcula_duracion = (root) ->
  datos = {
    fechainicio_localizada: $('#proyectofinanciero_fechainicio_localizada').val(),
    fechacierre_localizada: $('#proyectofinanciero_fechacierre_localizada').val()
  }
  if datos.fechainicio_localizada != '' && datos.fechacierre_localizada != ''
    sip_ajax_recibe_json(root, 'api/cor1440cinep/duracion',
      datos, establece_duracion)
  else
    $('#proyectofinanciero_duracion').val('')

@cor1440_cinep_recalcula_montospesos_localizado = (root) ->

  tfl = $('#proyectofinanciero_tasa_localizado').val()
  tf = reconocer_decimal_locale_es_CO(tfl)
  sum = 0
  sump = 0
  $.each [['monto', 'montopesos'], ['aportecinep', 'aportecinepp'],
          ['aotrosfin', 'aporteotrosp'], ['saldo', 'saldop']], (i, c) ->
    vl = $('#proyectofinanciero_' + c[0] + '_localizado').val()
    v = reconocer_decimal_locale_es_CO(vl)
    sum += v
    vp = v * tf 
    vpl = new Intl.NumberFormat('es-CO').format(vp)
    $('#proyectofinanciero_' + c[1] + '_localizado').val(vpl)
    sump += vp

  suml = new Intl.NumberFormat('es-CO').format(sum)
  sumpl = new Intl.NumberFormat('es-CO').format(sump)
  $('#proyectofinanciero_presupuestototal_localizado').val(suml)
  $('#proyectofinanciero_presupuestototalp_localizado').val(sumpl)

  # Repetimos para datos en ejecucion
  tel = $('#proyectofinanciero_tasaej_localizado').val()
  te = reconocer_decimal_locale_es_CO(tel)
  sum = 0
  sump = 0
  $.each [['montoej', 'montoejp'], ['aportecinepej', 'aportecinepejp'],
          ['aporteotrosej', 'aporteotrosejp'], ['saldoej', 'saldoejp']], (i, c) ->
    vl = $('#proyectofinanciero_' + c[0] + '_localizado').val()
    v = reconocer_decimal_locale_es_CO(vl)
    sum += v
    vp = v * te
    vpl = new Intl.NumberFormat('es-CO').format(vp)
    $('#proyectofinanciero_' + c[1] + '_localizado').val(vpl)
    sump += vp

  suml = new Intl.NumberFormat('es-CO').format(sum)
  sumpl = new Intl.NumberFormat('es-CO').format(sump)
  $('#proyectofinanciero_presupuestototalej_localizado').val(suml)
  $('#proyectofinanciero_presupuestototalejp_localizado').val(sumpl)


  return


@cor1440_gen_llena_medicion = (root, res) ->
  hid = res.hmindicadorpf_id
  $('[id$=_' + hid + '_fecha_localizada]').val(res.fechaloc)
  $('[id$=_' + hid + '_dmed1]').val(res.dmed1)
  $('[id$=_' + hid + '_dmed2]').val(res.dmed2)
  $('[id$=_' + hid + '_dmed3]').val(res.dmed3)
  $('[id$=_' + hid + '_rind]').val(res.rind)
  meta = +$('[id$=_' + hid + '_meta]').val()
  if ( meta > 0)
    $('[id$=_' + hid + '_porcump]').val(res.rind*100/meta)


@cor1440_gen_calcula_pmindicador = (elem, event) ->
  event.stopPropagation() 
  event.preventDefault() 
  root =  window
  r = $(elem).closest('tr')
  efinicio = r.find('[id$=finicio_localizada]')
  hid = efinicio.attr('id').replace(/.*_attributes_([0-9]*)_finicio_localizada/, '$1');
  datos = {
    finicio_localizada: efinicio.val()
    ffin_localizada: r.find('[id$=ffin_localizada]').val()
    indicadorpf_id: $(document).find('#mindicadorpf_indicadorpf_id').val()
    hmindicadorpf_id: hid
  }
  sip_ajax_recibe_json(root, 'api/cor1440cinep/mideindicador', 
    datos, cor1440_gen_llena_medicion)  
  return

@cor1440_cinep_cambia_tipomoneda = (root, res) ->
  if res.length > 0
    t = res[0]['presenta_nombre'].split(' ')[1]
  else 
    t = 0
  $('#proyectofinanciero_tasa_localizado').val(t)
  if $('#proyectofinanciero_tasaej_localizado').val() == ''
    $('#proyectofinanciero_tasaej_localizado').val(t)
  cor1440_cinep_recalcula_montospesos_localizado(root)


@cor1440_cinep_actividad_actualiza_camposdinamicos = (root) ->
  ruta = document.location.pathname
  if ruta.length == 0
    return
  if ruta[0] == '/'
    ruta = ruta.substr(1)
  datos = {
    actividadpf_ids: $('#actividad_actividadpf_ids').val()
  }
  sip_envia_ajax_datos_ruta_y_pinta(ruta, datos,
    '#camposdinamicos', '#camposdinamicos')

 
@cor1440_cinep_actividad_actualiza_actividadpf =  (root) ->
  params = {
    pfl: $('#actividad_proyectofinanciero_ids').val(),
  }
  sip_llena_select_con_AJAX2('actividadespf', params, 
    'actividad_actividadpf_ids', 'con Actividades de compromiso', root,
    'id', 'nombre', cor1440_cinep_actividad_actualiza_camposdinamicos)


@cor1440_cinep_actividad_actualiza_objetivopf =  (root) ->
  params = {
    pfl: $('#actividad_proyectofinanciero_ids').val(),
  }
  sip_llena_select_con_AJAX2('objetivospf', params,
    'actividad_objetivopf_ids', 'con Objetivos de compromiso', root,
    'id', 'nombre', cor1440_cinep_actividad_actualiza_actividadpf)


@cor1440_cinep_actividad_actualiza_actores = (root) ->
  params = {
    fecha: $('#actividad_fecha_localizada').val(),
    grupo_ids: $('#actividad_grupo_ids').val()
  }
  sip_llena_select_con_AJAX2('admin/actores', params, 
    'actividad_actor_ids', 'con Actores', 
    root, 'id', 'nombre', 
    cor1440_cinep_actividad_actualiza_objetivopf)

@cor1440_cinep_actividad_actualiza_pf = (root) ->
  params = {
    fecha: $('#actividad_fecha_localizada').val(),
    grupo_ids: $('#actividad_grupo_ids').val()
  }
  sip_llena_select_con_AJAX2('proyectosfinancieros', params, 
    'actividad_proyectofinanciero_ids', 'con Compromisos', 
    root, 'id', 'referenciacinep', 
    cor1440_cinep_actividad_actualiza_actores)

@cor1440_cinep_actividad_etnia_onr = (root) ->
  tg = parseInt($('#actividad_hombres').val()) + 
    parseInt($('#actividad_mujeres').val()) + 
    parseInt($('#actividad_sexo_onr').val())
  pe = parseInt($('#actividad_negros').val()) + 
    parseInt($('#actividad_indigenas').val())
  fe = 0
  if tg > pe
    fe = tg - pe
  $('#actividad_etnia_onr').val(fe)

@cor1440_cinep_actividad_totales_part = (root) ->
  tg = parseInt($('#actividad_hombres').val()) + 
    parseInt($('#actividad_mujeres').val()) + 
    parseInt($('#actividad_sexo_onr').val())
  te = parseInt($('#actividad_negros').val()) + 
    parseInt($('#actividad_indigenas').val()) +
    parseInt($('#actividad_etnia_onr').val())
  $('#tot_genero').html(tg)
  $('#tot_etnia').html(te)

@cor1440_cinep_prepara_eventos_unicos = (root) ->
  sip_arregla_puntomontaje(root)

  # Actividad
  $('#actividad_fecha_localizada').datepicker({
    format: root.formato_fecha,
    autoclose: true,
    todayHighlight: true,
    language: 'es'
  }).on('changeDate', (ev) ->
    cor1440_cinep_actividad_actualiza_pf(root)
  )

  $('#actividad_fecha_localizada').on('change', (ev) ->
    cor1440_cinep_actividad_actualiza_pf(root)
  )

  $('#actividad_grupo_ids').chosen().change( (e) ->
    cor1440_cinep_actividad_actualiza_pf(root)
  )

  $("#actividad_proyectofinanciero_ids").chosen().change( (e) ->
    cor1440_cinep_actividad_actualiza_objetivopf(root)
  )

  $('#actividad_actividadpf_ids').chosen().change( (e) ->
    cor1440_cinep_actividad_actualiza_camposdinamicos(root)
  )

  $('#actividad_mujeres').change( (e) ->
    cor1440_cinep_actividad_etnia_onr (root)
    cor1440_cinep_actividad_totales_part (root)
  )
  $('#actividad_hombres').change( (e) ->
    cor1440_cinep_actividad_etnia_onr (root)
    cor1440_cinep_actividad_totales_part (root)
  )
  $('#actividad_sexo_onr').change( (e) ->
    cor1440_cinep_actividad_etnia_onr (root)
    cor1440_cinep_actividad_totales_part (root)
  )
  $('#actividad_negros').change( (e) ->
    cor1440_cinep_actividad_etnia_onr (root)
    cor1440_cinep_actividad_totales_part (root)
  )
  $('#actividad_indigenas').change( (e) ->
    cor1440_cinep_actividad_etnia_onr (root)
    cor1440_cinep_actividad_totales_part (root)
  )
  $('#actividad_etnia_onr').change( (e) ->
    cor1440_cinep_actividad_totales_part (root)
  )

  # Efecto
  $(document).on('change', '#efecto_indicadorpf_id', (e) ->
    ruta = document.location.pathname
    if ruta.length == 0
      return
    if ruta[0] == '/'
      ruta = ruta.substr(1)
    datos = {
      indicadorpf_id: $(this).val()
    }
    sip_envia_ajax_datos_ruta_y_pinta(ruta, datos,
      '#camposdinamicos', '#camposdinamicos')

  )


  # Proyecto financiero - Compromiso Institucional
  #

  #$(document).on('click', 'a.enviarautomatico_y_repintapf[href^="#"]', (e) ->
  #  tabact = $('li.active[role=presentation] a').attr('href').substr(1)
  #  ltabf = $('li[role=presentation] a')
  #  ltab = []
  #  ltab.push(ltabf[i].hash.substr(1)) for i in [0 .. (ltabf.length-1)]
  #  d = ltab.filter (l) -> l != tabact

  #  sip_enviarautomatico_formulario_y_repinta($('form').attr('id'), 
  #    d, 'POST', false)
  #  return
  #)

  # En pestañas:
 
  # antes de mostrar una pestaña repintarla
  $('a.enviarautomatico_formulario_y_repintapf[data-toggle="tab"]').on('hide.bs.tab', (e) ->
    # e.target.hash.substr(1) # pestaña anterior
    idp = e.relatedTarget.hash.substr(1) # nueva pestaña
    sip_enviarautomatico_formulario_y_repinta($('form').attr('id'), 
      [idp], 'POST', false)
  ) 

  # Después de mostrar una pestaña repintar las demás que quedan escondidas 
  $('a.enviarautomatico_y_repintapf[data-toggle="tab"]').on('hidden.bs.tab', (e) ->
    # e.target.hash.substr(1) # pestaña anterior
    idn = e.relatedTarget.hash.substr(1) # nueva pestaña
    ltabf = $('li[role=presentation] a')
    ltab = []
    ltab.push(ltabf[i].hash.substr(1)) for i in [0 .. (ltabf.length-1)]
    d = ltab.filter (l) -> l != idn

    sip_enviarautomatico_formulario_y_repinta($('form').attr('id'), 
      d, 'POST', false)
  ) 
 
  $('#proyectofinanciero_tipomoneda_id').change( (e) ->
      val = $(this).val()
      if val == "1"  # PESO
        $('#proyectofinanciero_tasa_localizado').val(1)
        $('#proyectofinanciero_tasaej_localizado').val(1)
        cor1440_cinep_recalcula_montospesos_localizado(root)
      else
        param = {}
        param['bustipomoneda_id'] = val
        param['presenta_nombre'] = 1
        param['aniomax'] = $('#proyectofinanciero_fechaformulacion_anio').val()
        param['mesmax'] = $('#proyectofinanciero_fechaformulacion_mes').val()
        param = {filtro: param}
        sip_ajax_recibe_json(root, 'tasascambio', param, 
          cor1440_cinep_cambia_tipomoneda)
  )
  $('#proyectofinanciero_tasa_localizado').change( (e) ->
    cor1440_cinep_recalcula_montospesos_localizado(root)
  )
  $('#proyectofinanciero_tasaej_localizado').change( (e) ->
    cor1440_cinep_recalcula_montospesos_localizado(root)
  )

  $.each ['monto', 'aportecinep', 'aotrosfin', 'saldo', 'saldop',
    'montoej', 'aportecinepej', 'aporteotrosej', 'saldoej'], (i, c) ->
    $('#proyectofinanciero_' + c + '_localizado').change( (e) ->
      cor1440_cinep_recalcula_montospesos_localizado(root)
    )

  $('#proyectofinanciero_monto_localizado').change( (e) ->
    cor1440_cinep_recalcula_montospesos_localizado(root)
  )
  $('#proyectofinanciero_presupuestototal_localizado').change( (e) ->
    cor1440_cinep_recalcula_montospesos_localizado(root)
  )
  $('#proyectofinanciero_tasaformulacion_id').chosen().change( (e) ->
    cor1440_cinep_recalcula_montospesos_localizado(root)
  )

  $('#proyectofinanciero_fechaformulacion_mes').change( (e) ->
    s = 2
    if $('#proyectofinanciero_fechaformulacion_mes').val() <= 6
      s = 1
    $('#proyectofinanciero_semestreformulacion').val(s)
  )

  $('#proyectofinanciero_fechainicio_localizada').change( (e) ->
    recalcula_duracion(root)
  )
  $('#proyectofinanciero_fechacierre_localizada').change( (e) ->
    recalcula_duracion(root)
  )

  $('#proyectofinanciero_estado').chosen().change( (e) ->
    if $(this).val() == 'E'
      $('.editable-entramite').removeAttr('readonly')
      $('.editable-entramite.chosen-select').off()
      $('.editable-entramite.chosen-select').on('chosen:updated', () ->
        $(this).removeAttr('disabled');
        $(this).removeAttr('readonly');
        $(this).data('chosen').search_field_disabled();
      );
      $('.editable-entramite.chosen-select').trigger('chosen:updated')
    else
      $('.editable-entramite').attr('readonly', 'readonly')
      $('.editable-entramite.chosen-select').off()
      $('.editable-entramite.chosen-select').on('chosen:updated', () ->
        $(this).attr('disabled', 'disabled');
        $(this).attr('readonly', 'readonly');
        $(this).data('chosen').search_field_disabled();
      );
      $('.editable-entramite.chosen-select').trigger('chosen:updated')
    if $(this).val() == 'J'
      $('.editable-enejecucion').removeAttr('readonly')
      $('.editable-enejecucion.chosen-select').off()
      $('.editable-enejecucion.chosen-select').on('chosen:updated', () ->
        $(this).removeAttr('disabled');
        $(this).removeAttr('readonly');
        $(this).data('chosen').search_field_disabled();
      );
      $('.editable-enejecucion.chosen-select').trigger('chosen:updated')
    else
      $('.editable-enejecucion').attr('readonly', 'readonly')
      $('.editable-enejecucion.chosen-select').off()
      $('.editable-enejecucion.chosen-select').on('chosen:updated', () ->
        $(this).attr('disabled', 'disabled');
        $(this).attr('readonly', 'readonly');
        $(this).data('chosen').search_field_disabled();
      );
      $('.editable-enejecucion.chosen-select').trigger('chosen:updated')
  )

  $('#proyectofinanciero_estado').trigger('change')

  $(document).on('change', '[id^=proyectofinanciero_proyectofinanciero_usuario_attributes][id$=usuario_id]', (e, inserted) ->
    id=$(this).attr('id')
     
    aid_tipocontrato= id.replace('usuario_id', 'tipocontrato_id')
    aid_perfilprofesional = id.replace('usuario_id', 'perfilprofesional_id')
   
    lid = [] 
    lcampo = [] 
    vp = $('#' + aid_perfilprofesional).val() 
    if vp == '' || vp == '1'
      lid.push([aid_perfilprofesional, 'perfilprofesional_id'])
    vtn = $('#' + aid_tipocontrato).val() 
    if vtn == '' || vtn == '1'
      lid.push([aid_tipocontrato, 'tipocontrato_id'])
    if lid.length > 0
      sip_elige_opcion_select_con_AJAX($(this),  'usuarios', 
        lid, 'Datos de usuario')
  )

  $('#proyectofinanciero_grupo_ids').chosen().change( (e) ->
    return
    sip_arregla_puntomontaje(root)
    t = Date.now()
    d = -1
    if (root.change_proyectofinanciero_grupo_ids_t)
      d = (t - root.change_proyectofinanciero_grupo_ids_t)/1000
    root.change_proyectofinanciero_grupo_ids_t = t
    # NO se permite mas de un envio en 2 segundos 
    if (d > 0 && d <= 2)
      return
  
    l = $(this).val()
    param = {filtro: {
      ids: l
    }}
    x = $.getJSON(root.puntomontaje + 'admin/grupos/coordinadores.json', param)
    x.done((data) ->
      if data.length > 0
        data.forEach( (c) ->
           
        )
    )
    x.error((m1, m2, m3) -> 
      alert(
        'Problema al buscar coordinadores. ' + param + ' ' + m1 + ' ' + m2 + ' ' + m3)
      )

    # Obtener coordinador de la línea y si falta agregarlo como
    # coordinador 

  )


  # Usuario
 
  $('#usuario_sip_grupo_ids').chosen().change( (e) ->
    #usuario_gruposysupragrupos
    ids=$(this).val()
    if !Array.isArray(ids)
      ids = [ids]
    params = { ids: ids }
    actualiza_procesogh = (root) ->
      sip_cambia_cuadrotexto_AJAX('admin/grupos/procesosgh', params,
        'usuario_contrato_attributes_procesogh', 'Procesogh')
    sip_cambia_cuadrotexto_AJAX('admin/grupos/supragrupos', params,
        'usuario_gruposysupragrupos', 'Supragrupos', actualiza_procesogh)
      
  )

  $('#usuario_profesion_id').change( (e) ->
    idp=$(this).val()
    params = { id: idp }
    sip_cambia_cuadrotexto_AJAX('admin/profesiones/' + idp + '/areaestudios', 
      params, 'usuario_areaestudios', 'Area de estudios')
      
  )

  $('#usuario_contrato_attributes_tipocontrato_id').change ( (e) ->
    idt=$(this).val()
    params = { id: idt }
    sip_cambia_cuadrotexto_AJAX('admin/tiposcontratos/' + idt + '/tiponomina', 
      params, 'usuario_contrato_attributes_tiponomina', 'Tipo de nomina')
  )


  # Si se agrega con cocoon un campo de seleccion que se espera con
  # chosen, usa chosen
  $(document).on('cocoon:after-insert', '', (e,inserted) ->
    inserted.find('select[class*=chosen-select]').chosen()
  )

  return

