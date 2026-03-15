{{/*
Expand the name of the chart.
*/}}
{{- define "vibe-kanban.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
Truncated at 63 chars per DNS spec. If release name contains chart name it is used as the full name.
*/}}
{{- define "vibe-kanban.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name + version label used by the chart label.
*/}}
{{- define "vibe-kanban.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "vibe-kanban.labels" -}}
helm.sh/chart: {{ include "vibe-kanban.chart" . }}
{{ include "vibe-kanban.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — used in matchLabels and podSelector.
*/}}
{{- define "vibe-kanban.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vibe-kanban.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "vibe-kanban.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "vibe-kanban.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Component-specific names.
*/}}
{{- define "vibe-kanban.server.fullname" -}}
{{- printf "%s-server" (include "vibe-kanban.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "vibe-kanban.postgres.fullname" -}}
{{- printf "%s-postgres" (include "vibe-kanban.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "vibe-kanban.electric.fullname" -}}
{{- printf "%s-electric" (include "vibe-kanban.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "vibe-kanban.relay.fullname" -}}
{{- printf "%s-relay" (include "vibe-kanban.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "vibe-kanban.worker.fullname" -}}
{{- printf "%s-worker" (include "vibe-kanban.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Secret name holding all sensitive credentials.
Returns the existingSecret name when provided, otherwise the chart-managed secret.
*/}}
{{- define "vibe-kanban.secretName" -}}
{{- .Values.secrets.existingSecret | default (printf "%s-credentials" (include "vibe-kanban.fullname" .)) }}
{{- end }}

{{/*
PostgreSQL internal service hostname.
*/}}
{{- define "vibe-kanban.postgres.host" -}}
{{- include "vibe-kanban.postgres.fullname" . }}
{{- end }}

{{/*
PostgreSQL connection URL for the remote-server.
*/}}
{{- define "vibe-kanban.postgres.serverUrl" -}}
{{- printf "postgres://%s@%s:5432/%s" .Values.postgres.username (include "vibe-kanban.postgres.host" .) .Values.postgres.database }}
{{- end }}

{{/*
PostgreSQL connection URL for ElectricSQL (electric_sync role).
*/}}
{{- define "vibe-kanban.postgres.electricUrl" -}}
{{- printf "postgresql://electric_sync@%s:5432/%s?sslmode=disable" (include "vibe-kanban.postgres.host" .) .Values.postgres.database }}
{{- end }}

{{/*
ElectricSQL internal service URL used by the remote-server.
*/}}
{{- define "vibe-kanban.electric.url" -}}
{{- printf "http://%s:3000" (include "vibe-kanban.electric.fullname" .) }}
{{- end }}

{{/*
Component selector labels helpers — append component label to common selectors.
*/}}
{{- define "vibe-kanban.server.selectorLabels" -}}
{{ include "vibe-kanban.selectorLabels" . }}
app.kubernetes.io/component: server
{{- end }}

{{- define "vibe-kanban.postgres.selectorLabels" -}}
{{ include "vibe-kanban.selectorLabels" . }}
app.kubernetes.io/component: postgres
{{- end }}

{{- define "vibe-kanban.electric.selectorLabels" -}}
{{ include "vibe-kanban.selectorLabels" . }}
app.kubernetes.io/component: electric
{{- end }}

{{- define "vibe-kanban.relay.selectorLabels" -}}
{{ include "vibe-kanban.selectorLabels" . }}
app.kubernetes.io/component: relay
{{- end }}

{{- define "vibe-kanban.worker.selectorLabels" -}}
{{ include "vibe-kanban.selectorLabels" . }}
app.kubernetes.io/component: worker
{{- end }}
