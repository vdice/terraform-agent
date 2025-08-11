{{- define "tfc-agent.name" -}}
tfc-agent
{{- end }}

{{- define "tfc-agent.fullname" -}}
{{ .Release.Name }}-tfc-agent
{{- end }}
