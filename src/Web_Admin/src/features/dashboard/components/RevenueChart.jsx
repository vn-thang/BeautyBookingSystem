import React, { useState } from 'react';
import { Radio } from 'antd';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { LineChartOutlined } from '@ant-design/icons';
import SectionCard from '../../../components/SectionCard';

const RevenueChart = ({ data }) => {
    const [chartMode, setChartMode] = useState('revenue'); 

    const formattedData = data?.map(item => ({
        name: item.day ? `${item.day}/${item.month}` : `T${item.month}/${item.year}`,
        revenue: item.revenue || 0,
        commission: item.commission || 0 
    })) || [];

    const formatCurrency = (value) => {
        if (value >= 1000000) return `${(value / 1000000).toFixed(1)}M`;
        return value.toLocaleString();
    };

    const isRevenueMode = chartMode === 'revenue';
    const activeDataKey = isRevenueMode ? 'revenue' : 'commission';
    const activeColor = isRevenueMode ? '#8c8c8c' : '#4318FF'; 
    const activeGradient = isRevenueMode ? 'colorRevenue' : 'colorCommission';
    const tooltipLabel = isRevenueMode ? 'Tổng giao dịch (GMV)' : 'Hoa hồng thực nhận';

    return (
        <SectionCard 
            title="Biểu đồ Doanh thu hệ thống" 
            icon={<LineChartOutlined style={{ color: '#4318FF' }} />}
            style={{ marginBottom: 0, height: '100%' }}
        >
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 24 }}>
                <Radio.Group 
                    value={chartMode} 
                    onChange={(e) => setChartMode(e.target.value)} 
                    buttonStyle="solid"
                >
                    <Radio.Button value="revenue">Tổng Giao Dịch</Radio.Button>
                    <Radio.Button value="commission">Hoa Hồng Nền Tảng</Radio.Button>
                </Radio.Group>
            </div>
            
            <ResponsiveContainer width="100%" height={350}>
                <AreaChart data={formattedData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                    <defs>
                        <linearGradient id="colorRevenue" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%" stopColor="#8c8c8c" stopOpacity={0.3}/>
                            <stop offset="95%" stopColor="#8c8c8c" stopOpacity={0}/>
                        </linearGradient>
                        <linearGradient id="colorCommission" x1="0" y1="0" x2="0" y2="1">
                            <stop offset="5%" stopColor="#4318FF" stopOpacity={0.3}/>
                            <stop offset="95%" stopColor="#4318FF" stopOpacity={0}/>
                        </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                    <XAxis 
                        dataKey="name" 
                        axisLine={false} 
                        tickLine={false} 
                        tick={{ fill: '#64748b', fontSize: 12 }} 
                        dy={10}
                    />
                    <YAxis 
                        tickFormatter={formatCurrency} 
                        axisLine={false} 
                        tickLine={false} 
                        tick={{ fill: '#64748b', fontSize: 12 }}
                        dx={-10}
                    />
                    <Tooltip 
                        formatter={(value) => [`${value.toLocaleString()} ₫`, tooltipLabel]}
                        contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}
                    />
                    <Area 
                        type="monotone" 
                        dataKey={activeDataKey} 
                        stroke={activeColor} 
                        strokeWidth={3}
                        fillOpacity={1} 
                        fill={`url(#${activeGradient})`} 
                        activeDot={{ r: 6, strokeWidth: 0, stroke: activeColor }}
                    />
                </AreaChart>
            </ResponsiveContainer>
        </SectionCard>
    );
};

export default RevenueChart;