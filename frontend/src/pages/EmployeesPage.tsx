import React from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { 
  deleteEmployee, 
  selectEmployee, 
  openNewEmployeeModal 
} from '../store/shiftsSlice';
import EmployeeModal from '../components/EmployeeModal';
import LanguageSelector from '../components/LanguageSelector';

const EmployeesPage: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const { employees, isEmployeeModalOpen } = useSelector((state: RootState) => state.shifts);

  const handleAddEmployee = () => {
    dispatch(openNewEmployeeModal());
  };

  const handleEditEmployee = (id: string) => {
    dispatch(selectEmployee(id));
  };

  const handleDeleteEmployee = (id: string) => {
    if (window.confirm(t('employees.confirmDelete'))) {
      dispatch(deleteEmployee(id));
    }
  };

  return (
    <div className="container mx-auto p-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800">{t('employees.title')}</h1>
        <div className="flex space-x-4">
          <LanguageSelector />
          <button
            onClick={handleAddEmployee}
            className="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 transition-colors"
          >
            {t('employees.addEmployee')}
          </button>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.name')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.role')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.type')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.skills')}
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.actions')}
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {employees.map((employee) => (
              <tr key={employee.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {employee.name}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {employee.role}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {t(`employees.types.${employee.employmentType}`)}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <div className="flex flex-wrap gap-1">
                    {employee.skills.map((skill, index) => (
                      <span 
                        key={index} 
                        className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-primary-100 text-primary-800"
                      >
                        {skill}
                      </span>
                    ))}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex justify-end space-x-2">
                    <button
                      onClick={() => handleEditEmployee(employee.id)}
                      className="text-indigo-600 hover:text-indigo-900"
                    >
                      {t('employees.edit')}
                    </button>
                    <button
                      onClick={() => handleDeleteEmployee(employee.id)}
                      className="text-red-600 hover:text-red-900"
                    >
                      {t('employees.delete')}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {isEmployeeModalOpen && <EmployeeModal />}
    </div>
  );
};

export default EmployeesPage;
