import React from 'react';
import { useState, FunctionComponent } from 'react';

interface ProcessValue {
  id: string | null;
  name: string;
  command: string;
  dockerfile: string;
  expose_port: string;
}

interface Props {
  values: Array<ProcessValue>
}

interface ProcessIndex {
  index: number;
  defaultValue: ProcessValue | null;
}

const lastIndexFor = (envs: Array<ProcessIndex>) => {
  if (envs.length < 1) {
    return 0;
  }

  return envs[envs.length - 1].index + 1;
};

const prepareIndices = (props: Props) => {
  if (props.values.length < 1) {
    return [{
      index: 0,
      defaultValue: { name: "web", command: "", dockerfile: "", expose_port: "80" } as ProcessValue
    } as ProcessIndex]
  }
  return props.values.map((value: ProcessValue, index: number) => (
    { index: index, defaultValue: value } as ProcessIndex
  ))
};

const ProcessesFields: FunctionComponent<Props> = (props: Props) => {
  const [processes, setProcesses] = useState<Array<ProcessIndex>>(prepareIndices(props))

  return (
    <div className="notification mt-5">
      <div className="mb-5">
        <label className="label">Processes</label>
        <small>Environment variables for Docker build. These values are being used by ARG and ENV Docker instructions</small>
      </div>
      {processes.length > 0 &&
        <div className="columns is-mobile mb-0">
          <div className="column is-2"><small>Name</small></div>
          <div className="column"><small>Command</small></div>
          <div className="column is-3"><small>Dockerfile path</small></div>
          <div className="column is-2"><small>Port</small></div>
        </div>
      }
      {
        processes.map((process: ProcessIndex) => (
          <div className="columns is-mobile mb-0" key={process.index}>
            {process.defaultValue?.id &&
              <input name={`repository[web_processes_attributes][${process.index}][id]`} value={process.defaultValue.id} type="hidden" />
            }
            <div className="column is-2">
              {process.defaultValue?.name === "web" ?
                <div className="has-text-centered is-family-monospace">
                  <input name={`repository[web_processes_attributes][${process.index}][name]`} value="web" type="hidden" />
                  web
                </div>
                :
                <input
                  className="input is-family-monospace"
                  name={`repository[web_processes_attributes][${process.index}][name]`}
                  defaultValue={process.defaultValue?.name}
                  placeholder="process name"
                  autoComplete="hidden"
                  type="text" />
              }
            </div>
            <div className="column">
              <input
                className="input is-family-monospace"
                name={`repository[web_processes_attributes][${process.index}][command]`}
                defaultValue={process.defaultValue?.command}
                placeholder="command"
                autoComplete="hidden"
                type="text" />
            </div>
            <div className="column is-3">
              <input
                className="input is-family-monospace"
                name={`repository[web_processes_attributes][${process.index}][dockerfile]`}
                defaultValue={process.defaultValue?.dockerfile}
                placeholder="./Dockerfile"
                autoComplete="hidden"
                type="text" />
            </div>
            <div className="column is-1">
              <input
                className="input is-family-monospace"
                name={`repository[web_processes_attributes][${process.index}][expose_port]`}
                defaultValue={process.defaultValue?.expose_port}
                placeholder="port"
                min="0"
                max="65535"
                autoComplete="hidden"
                type="number" />
            </div>
            <div className="column is-1">
              {
                (process.defaultValue?.name !== "web") &&
                  <button className="button" onClick={(e) => { e.preventDefault(); setProcesses(processes.filter(item => item !== process)) }}>
                    <i className="fas fa-times" />
                  </button>
              }
            </div>
          </div>
        ))
      }

      <div className="columns mb-0">
        <div className="column is-3">
          <button className="button" onClick={(e) => { e.preventDefault(); setProcesses([...processes, { index: lastIndexFor(processes) } as ProcessIndex]) }}>
            <i className="fas fa-plus" />&nbsp;Add new process
          </button>
        </div>
      </div>
    </div>
  )
}

export default (props: any) => <ProcessesFields {...props} />
