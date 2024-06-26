apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
spec:
  selector:
    app: ${SERVICE_NAME}
  ports:
    - protocol: TCP
      port: ${CONTAINER_PORT}
      targetPort: ${CONTAINER_PORT}
      nodePort: ${NODE_PORT}
  type: NodePort