import React from 'react';
import { useState, FunctionComponent } from 'react';

interface EnvValue {
  key: string;
  value: string;
}

interface Props {
  title: string;
  subtitle: string;
  fieldName: string
  values: Array<EnvValue>
}

interface EnvIndex {
  index: number;
  defaultValue: EnvValue | null;
}

const lastIndexFor = (envs: Array<EnvIndex>) => {
  if (envs.length < 1) {
    return 0;
  }

  return envs[envs.length - 1].index + 1;
};

const EnvVarFields: FunctionComponent<Props> = (props: Props) => {
  const values = props.values.map((value: EnvValue, index: number) => ({ index: index, defaultValue: value } as EnvIndex))
  const [envs, setEnvs] = useState<Array<EnvIndex>>(values)

  return (
    <div className="notification mt-5">
      <div className="mb-5">
        <label className="label">{props.title}</label>
        <small>{props.subtitle}</small>
      </div>
      {envs.length > 0 &&
        <div className="columns is-mobile mb-0">
          <div className="column is-3">
            <small>Key</small>
          </div>
          <div className="column is-9">
            <small>Value</small>
          </div>
        </div>
      }

      {!envs.length &&
        <input name={`repository[${props.fieldName}][0]`} value="" type="hidden" />
      }

      {
        envs.map((envVar: EnvIndex) => (
          <div className="columns is-mobile mb-0" key={envVar.index}>
            <div className="column is-3">
              <input
                className="input is-family-monospace"
                name={`repository[${props.fieldName}][${envVar.index}][key]`}
                defaultValue={envVar.defaultValue?.key}
                placeholder="name"
                autoComplete="hidden"
                type="text" />
            </div>
            <div className="column">
              <input
                className="input is-family-monospace"
                name={`repository[${props.fieldName}][${envVar.index}][value]`}
                defaultValue={envVar.defaultValue?.value}
                placeholder="value"
                autoComplete="hidden"
                type="text" />
            </div>
            <div className="column is-1">
              <button className="button" onClick={(e) => { e.preventDefault(); setEnvs(envs.filter(item => item !== envVar)) }}>
                <i className="fas fa-times" />
              </button>
            </div>
          </div>
        ))
      }

      <div className="columns mb-0">
        <div className="column is-3">
          <button className="button" onClick={(e) => { e.preventDefault(); setEnvs([...envs, { index: lastIndexFor(envs) } as EnvIndex]) }}>
            <i className="fas fa-plus" />&nbsp;Add new value
          </button>
        </div>
      </div>
    </div>
  )
}

export default (props: any) => <EnvVarFields {...props} />
