{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "generator-helm-chart.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "generator-helm-chart.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Calculate nginx certificate
*/}}
{{- define "generator-helm-chart.nginx-certificate" }}
{{- if (not (empty .Values.ingress.nginx.certificate)) }}
{{- printf .Values.ingress.nginx.certificate }}
{{- else }}
{{- printf "%s-nginx-letsencrypt" (include "generator-helm-chart.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate nginx hostname
*/}}
{{- define "generator-helm-chart.nginx-hostname" }}
{{- if (and .Values.config.nginx.hostname (not (empty .Values.config.nginx.hostname))) }}
{{- printf .Values.config.nginx.hostname }}
{{- else }}
{{- if .Values.ingress.nginx.enabled }}
{{- printf .Values.ingress.nginx.hostname }}
{{- else }}
{{- printf "%s-nginx" (include "generator-helm-chart.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate nginx base url
*/}}
{{- define "generator-helm-chart.nginx-base-url" }}
{{- if (and .Values.config.nginx.baseUrl (not (empty .Values.config.nginx.baseUrl))) }}
{{- printf .Values.config.nginx.baseUrl }}
{{- else }}
{{- if .Values.ingress.nginx.enabled }}
{{- $hostname := ((empty (include "generator-helm-chart.nginx-hostname" .)) | ternary .Values.ingress.nginx.hostname (include "generator-helm-chart.nginx-hostname" .)) }}
{{- $path := (eq .Values.ingress.nginx.path "/" | ternary "" .Values.ingress.nginx.path) }}
{{- $protocol := (.Values.ingress.nginx.tls | ternary "https" "http") }}
{{- printf "%s://%s%s" $protocol $hostname $path }}
{{- else }}
{{- printf "http://%s" (include "generator-helm-chart.nginx-hostname" .) }}
{{- end }}
{{- end }}
{{- end }}
