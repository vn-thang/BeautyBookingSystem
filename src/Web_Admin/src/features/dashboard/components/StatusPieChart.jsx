import React from 'react';
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { PieChartOutlined } from '@ant-design/icons';
import SectionCard from '../../../components/SectionCard';

const COLORS = {
    Completed: '#10b981',
    Pending: '#f59e0b',   
    Cancelled: '#ef4444', 
    Confirmed: '#3b82f6'  
};

const STATUS_VI = {
    Completed: 'Hoàn thành',
    Pending: 'Chờ duyệt',
    Cancelled: 'Đã hủy',
    Confirmed: 'Đã xác nhận',
     DepositPaid: 'Đã cọc'
};

const renderCustomizedLabel = ({ x, y, cx, percent }) => {
    if (percent === 0) return null;
    return (
        <text 
            x={x} y={y} 
            fill="#475569" 
            textAnchor={x > cx ? 'start' : 'end'} 
            dominantBaseline="central"
            fontSize={13} fontWeight={600}
        >
            {`${(percent * 100).toFixed(1)}%`}
        </text>
    );
};

const renderCustomLegend = (props) => {
    const { payload } = props;
    return (
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px 32px', width: 'max-content', margin: '16px auto 0' }}>
            {payload.map((entry, index) => (
                <div key={`item-${index}`} style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <div style={{ width: 10, height: 10, borderRadius: '50%', backgroundColor: entry.color }}></div>
                    <span style={{ color: '#475569', fontSize: '13px', fontWeight: 500 }}>
                        {STATUS_VI[entry.value] || entry.value}
                    </span>
                </div>
            ))}
        </div>
    );
};

const StatusPieChart = ({ data }) => {
    const chartData = data || [];

    return (
        <SectionCard 
            title="Tỉ lệ Trạng thái Lịch hẹn" 
            icon={<PieChartOutlined style={{ color: '#06b6d4' }} />}
            style={{ marginBottom: 0, height: '100%' }}
        >
            <ResponsiveContainer width="100%" height={300}>
                <PieChart margin={{ top: 20, right: 40, bottom: 20, left: 40 }}>
                    <Pie
                        data={chartData}
                        dataKey="count"
                        nameKey="status"
                        cx="50%" cy="50%"
                        innerRadius={60} outerRadius={80}
                        paddingAngle={5}
                        labelLine={{ stroke: '#cbd5e1', strokeWidth: 1 }} 
                        label={renderCustomizedLabel} 
                    >
                        {chartData.map((entry, index) => (
                            <Cell key={`cell-${index}`} fill={COLORS[entry.status] || '#d9d9d9'} />
                        ))}
                    </Pie>
                    <Tooltip 
                        formatter={(value, name) => {
                            const total = chartData.reduce((acc, curr) => acc + curr.count, 0);
                            const percent = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                            return [`${value} lịch hẹn (${percent}%)`, STATUS_VI[name] || name];
                        }}
                        contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
                    />
                    <Legend content={renderCustomLegend} verticalAlign="bottom" />
                </PieChart>
            </ResponsiveContainer>
        </SectionCard>
    );
};

export default StatusPieChart;